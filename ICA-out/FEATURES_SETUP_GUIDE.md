# ICA Website — Naye Features Setup Guide

## ✅ Naye Features
1. **Document Viewer** — Admin admission application kholke har document (photo, birth cert, marksheet, TC, Aadhaar) dekh/download kar sakta hai (Admissions → View → "View Documents")
2. **Professional Confirmation Slip** — Student photo + application number ke saath print-ready slip (Admissions → View → "Confirmation Slip")
3. **Sequential Application Numbers** — Format: `ICA/2026/0001`, har academic year ke liye alag counter
4. **Admission Form Builder** — Admin Panel → Form Builder: sections/fields add/edit/delete kar sakte ho
5. **Custom Forms** — Admin Panel → Form Responses: koi bhi naya form bana ke website par publish kar sakte ho
6. **Site Settings** — Admin Panel → Site Settings: Admission Year aur Theme colors change kar sakte ho

---

## 🚨 ZAROORI STEP — Database Update Karo Pehle!

Naye features kaam karne ke liye Supabase mein **SCHEMA_UPDATE.sql** file ka SQL run karna hoga.

### Steps:
1. **Supabase Dashboard** → apna project kholo
2. Left sidebar → **SQL Editor** → **New Query**
3. `SCHEMA_UPDATE.sql` file ka **pura content copy-paste karo**
4. **RUN** dabao
5. "Success" message aana chahiye

### Storage Bucket (Documents ke liye)
SQL mein automatically `admission-docs` bucket ban jayega. Agar error aaye to manually banao:
1. Supabase → **Storage** → **New Bucket**
2. Name: `admission-docs`
3. **Public bucket: YES** (zaroori hai, taaki admin documents dekh sake)
4. Create

---

## 📦 Deploy Karne Ka Tareeka

1. Is poore folder ko ZIP karke Netlify par upload karo (ya GitHub push karo)
2. **Environment Variables** check karo (already set hone chahiye):
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_KEY`
   - `ADMIN_TOKEN`
3. Deploy karo

---

## 🎯 Pehli Baar Use Karne Ka Order

1. **Admin Login** karo
2. **Site Settings** → Admission Year set karo (e.g. `2026-27`) → Save
3. **Form Builder** → Default sections dikhenge, chaho to edit karo → **Publish Live**
4. **Dashboard** → Admission toggle ON karo
5. Website par "Apply Now" test karo — form khulna chahiye, documents upload, submit
6. **Admissions** panel mein application dikhega — "Docs" button se documents dekho
7. Status "Confirmed" karo → "Confirmation Slip" print karo

---

## ⚠️ Important Notes

- **Purane admissions records** (jo schema update se pehle submit hue) unme `application_number` aur document URLs khali honge — sirf naye submissions se yeh kaam karega.
- Document upload mein thoda time lag sakta hai (5 files upload ho rahe hain ek saath) — "Submitting..." dikhega.
- File size limit: 2MB per document (already form mein check hai).
- Custom Forms abhi simple text/select fields support karte hain — file upload custom forms mein available nahi hai (sirf Admission form mein hai).
