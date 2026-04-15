// tools/vehicle_import/import.js
const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

const serviceAccount = require("./serviceAccount.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

function brandKeyOf(brandName) {
  return brandName
    .toLowerCase()
    .trim()
    .replace(/&/g, "and")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

async function commitBatchWithLimit(ops, limit = 450) {
  // Firestore batch limit is 500; keep margin
  for (let i = 0; i < ops.length; i += limit) {
    const chunk = ops.slice(i, i + limit);
    const batch = db.batch();
    chunk.forEach((fn) => fn(batch));
    await batch.commit();
    console.log(`Committed batch ${i / limit + 1} (${chunk.length} writes)`);
  }
}

async function run() {
  const dataPath = path.join(__dirname, "vehicles_my.json");
  const raw = fs.readFileSync(dataPath, "utf8");
  const data = JSON.parse(raw);

  const brandOps = [];
  const modelOps = [];

  const brands = Object.keys(data);
  console.log(`Brands: ${brands.length}`);

  for (const brandName of brands) {
    const bKey = brandKeyOf(brandName);

    // vehicle_brands doc id = bKey (stable)
    const brandRef = db.collection("vehicle_brands").doc(bKey);
    brandOps.push((batch) =>
      batch.set(
        brandRef,
        {
          name: brandName,
          brandKey: bKey,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      )
    );

    const modelsObj = data[brandName]; // { "Myvi": {type, minutes}, ... }
    const modelNames = Object.keys(modelsObj || {});
    for (const modelName of modelNames) {
      const details = modelsObj[modelName] || {};

      // deterministic model id to avoid duplicates:
      // vehicle_models/{brandKey__searchName}
      const searchName = String(modelName).toLowerCase().trim();
      const modelId = `${bKey}__${searchName.replace(/[^a-z0-9]+/g, "-")}`;

      const modelRef = db.collection("vehicle_models").doc(modelId);
      modelOps.push((batch) =>
        batch.set(
          modelRef,
          {
            brandKey: bKey,
            brandName: brandName,
            name: modelName,
            searchName: searchName,
            type: details.type ?? null,
            minutes: Number.isFinite(details.minutes) ? details.minutes : null,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        )
      );
    }
  }

  console.log(`Writes: brands=${brandOps.length}, models=${modelOps.length}`);
  await commitBatchWithLimit(brandOps);
  await commitBatchWithLimit(modelOps);

  console.log("Import done.");
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});