const { onRequest } = require("firebase-functions/v2/https");
const { GoogleGenerativeAI, HarmCategory, HarmBlockThreshold } = require("@google/generative-ai");
const axios = require("axios");
const pdf = require("pdf-parse");
const fs = require("fs");

const genAI = new GoogleGenerativeAI("AIzaSyC-4CO05Liy0wq6IGhJP5HG9wIKfDjEk_E"); 

// === MODELLER ===
const model = genAI.getGenerativeModel({ model: "models/gemini-2.5-pro" });
const visionModel = genAI.getGenerativeModel({
  model: "models/gemini-1.5-pro-latest",
  safetySettings: [
    {
      category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
      threshold: HarmBlockThreshold.BLOCK_NONE,
    },
  ],
});

// === PDF Prospektüs Analizi ===
exports.parseProspektusPDF = onRequest(async (req, res) => {
  try {
    const { pdfUrl } = req.body;
    if (!pdfUrl) return res.status(400).send("pdfUrl eksik");

    const response = await axios.get(pdfUrl, { responseType: "arraybuffer" });
    const data = await pdf(response.data);

    const prompt = `Aşağıdaki prospektüs metninden şu bilgileri çıkar ve JSON formatında ver:

- etken_madde
- kullanim_amaci
- dozaj
- yan_etkiler
- kontrendikasyonlar
- hamilelik
- saklama

Sadece JSON döndür. Açıklama veya başka bir şey yazma.

Metin:
${data.text}`;

    const result = await model.generateContent(prompt);
    const output = result.response.text();
    res.send(output);
  } catch (error) {
    console.error("Hata:", error);
    res.status(500).send("Bir hata oluştu: " + error.message);
  }
});

// === İlaç Etkileşim Kontrolü ===
exports.checkDrugInteraction = onRequest(async (req, res) => {
  try {
    const { drugA, drugB } = req.body;

    const prompt = `${drugA} ve ${drugB} ilaçları birlikte kullanılabilir mi?
Etkileşim riski var mı? Ciddi yan etkiler oluşur mu? Tıbbi literatürde bu konuda bilinenler nelerdir?
Kısa ve sade bir şekilde açıklayınız.`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    res.status(200).send({ interactionAnalysis: text });
  } catch (error) {
    console.error("Bir hata oluştu:", error);
    res.status(500).send("Hata: " + error.message);
  }
});

// === Yan Etki Analizi ===
exports.checkSideEffect = onRequest(async (req, res) => {
  try {
    const { sideEffect, drug } = req.body;
    if (!sideEffect || !drug) {
      return res.status(400).send("Eksik bilgi: 'sideEffect' ve 'drug' gereklidir.");
    }

    const prompt = `"${drug}" ilacını kullanan bir kişi "${sideEffect}" yan etkisini yaşıyor.

- Bu yan etki bu ilaçla ilişkili midir?
- Bilinen bir yan etki midir?
- Ciddi bir yan etki midir?
- Kullanıcı tıbbi yardım almalı mı?

Cevabı kısa tut. Sadece gerekli tıbbi uyarı varsa belirt.`;

    const result = await model.generateContent(prompt);
    const output = result.response.text();

    res.status(200).send({ analysis: output });
  } catch (error) {
    console.error("Yan etki analiz hatası:", error);
    res.status(500).send("Hata: " + error.message);
  }
});

// === Reçete Görseli Analizi  ===
exports.parsePrescriptionImage = onRequest(async (req, res) => {
  try {
    let imageBase64 = req.body.imageBase64;
    const imagePath = req.body.imagePath;

    if (!imageBase64 && !imagePath) {
      return res.status(400).send("imageBase64 veya imagePath belirtmelisiniz.");
    }

    if (!imageBase64 && imagePath) {
      imageBase64 = fs.readFileSync(imagePath, { encoding: "base64" });
    }

    const imagePart = {
      inlineData: {
        data: imageBase64,
        mimeType: "image/jpeg",
      },
    };

    const prompt = `Aşağıdaki reçete görüntüsünden şu bilgileri çıkar ve JSON formatında döndür:
- ilac_adi
- dozaj
- kullanim_sikligi
- kullanim_suresi

Sadece geçerli JSON verisi döndür. Açıklama yazma.`;

    const result = await visionModel.generateContent({
      contents: [
        {
          role: "user",
          parts: [{ text: prompt }, imagePart],
        },
      ],
    });

    const text = result.response.text();
    res.status(200).send({ parsedPrescription: text });

  } catch (error) {
    console.error("Görsel yorumlama hatası:", error);
    res.status(500).send("Bir hata oluştu: " + error.message);
  }
});
