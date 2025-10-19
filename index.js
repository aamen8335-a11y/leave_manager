const functions = require('firebase-functions/v2');
const admin = require('firebase-admin');
admin.initializeApp();

// New leave request notification
exports.notifyOnNewLeave = functions.firestore.onDocumentCreated('leave_requests/{id}', async (event) => {
  const data = event.data.data();
  const { teamId, department } = data;
  const typeMap = { annual: 'سنوية', sick: 'مرضية', unpaid: 'بدون راتب', other: 'أخرى' };
  const typeAr = typeMap[data.type] || 'أخرى';

  const usersSnap = await admin.firestore().collection('users')
    .where('role', 'in', ['team_leader','supervisor'])
    .get();

  const tokens = [];
  usersSnap.forEach(doc => {
    const u = doc.data();
    const inScope = (u.role === 'team_leader' && u.teamId === teamId) ||
                    (u.role === 'supervisor' && u.department === department) ||
                    (u.isCompanyAdmin === true);
    if (inScope && u.fcmToken) tokens.push(u.fcmToken);
  });

  if (tokens.length) {
    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: { title: 'طلب إجازة جديد', body: `${data.userName} قدم طلب (${typeAr})` }
    });
  }
});

// Status change notification (approve/reject)
exports.notifyOnStatusChange = functions.firestore.onDocumentUpdated('leave_requests/{id}', async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (before.status === after.status) return;

  const userDoc = await admin.firestore().collection('users').doc(after.userId).get();
  const token = userDoc.data()?.fcmToken;
  if (!token) return;

  const title = after.status === 'approved' ? 'تمت الموافقة على طلبك' : 'تم رفض طلبك';
  const body = `${after.approverName || 'المشرف'}: ${after.approverNote || ''}`;

  await admin.messaging().sendEachForMulticast({
    tokens: [token],
    notification: { title, body }
  });
});

// Shift change notifications (to user + team leader + company admins)
exports.notifyOnShiftChange = functions.firestore.onDocumentUpdated('users/{uid}', async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  const depBefore = before.department || '';
  const depAfter = after.department || '';
  const teamAfter = after.teamId || '';
  if (depBefore === depAfter && (before.teamId || '') === teamAfter) return;

  const notifs = [];
  const userToken = after.fcmToken;
  if (userToken) {
    notifs.push(admin.messaging().sendEachForMulticast({
      tokens: [userToken],
      notification: { title: 'تم تحديث الشِفت الخاص بك', body: `من ${depBefore || 'غير محدد'} إلى ${depAfter || 'غير محدد'}` }
    }));
  }

  const usersSnap = await admin.firestore().collection('users')
    .where('role', 'in', ['team_leader','supervisor'])
    .get();
  const tlTokens = [];
  usersSnap.forEach(doc => {
    const u = doc.data();
    const isTLOfTeam = u.role === 'team_leader' && (u.teamId || '') === teamAfter;
    const isCompanyAdmin = u.isCompanyAdmin === true;
    if ((isTLOfTeam || isCompanyAdmin) && u.fcmToken) tlTokens.push(u.fcmToken);
  });
  if (tlTokens.length) {
    notifs.push(admin.messaging().sendEachForMulticast({
      tokens: tlTokens,
      notification: { title: 'تغيير شِفت لأحد أعضاء فريقك', body: `${after.displayName || 'موظف'} أصبح شِفته: ${depAfter}` }
    }));
  }
  await Promise.all(notifs);
});
