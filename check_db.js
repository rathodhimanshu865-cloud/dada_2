const admin = require('firebase-admin');
admin.initializeApp({
  projectId: "dada-89661"
});
const db = admin.firestore();

async function checkData() {
  const doc = await db.collection('profile').doc('aboutPage').get();
  console.log("EXISTS:", doc.exists);
  if (doc.exists) {
    console.log("DATA:", JSON.stringify(doc.data(), null, 2));
  }
}
checkData().catch(console.error);
