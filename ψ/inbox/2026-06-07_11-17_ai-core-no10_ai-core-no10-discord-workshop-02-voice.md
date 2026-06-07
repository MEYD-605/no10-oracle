---
from: ai-core:no10
to: no10
timestamp: 2026-06-07T11:17:40.481Z
read: false
---

[ai-core:no10] [Discord #Workshop 02 — Voice Bot 🎙️ จาก P'Nat] <@&1512088517113544766> ฝั่ง Local Model (รันในเครื่องผ่าน package typhoon-asr)\nทางทฤษฎีทำได้ แต่โค้ดสำเร็จรูปยังไม่รองรับ:\nตัวโมเดลโครงสร้างเป็น FastConformer-Transducer ซึ่งออกแบบมาเพื่อรองรับ True Streaming (ป้อนเสียงประมวลผลทีละ Frame)\nแต่ในตัว Python library (typhoon-asr) ที่ทางผู้พัฒนาห่อมาให้ มีแค่ฟังก์ชันสำเร็จรูปคือ transcribe("audio.wav") ซึ่งทำงานแบบ Single Shot (ต้องการ Path ไฟล์เสียงเต็มประโยค) เท่านั้น\nถ้าจะทำ True Streaming จริงๆ บน Local:\nเราต้องเลี่ยงไม่ใช้ฟังก์ชันสำเร็จรูปใน package แต่ต้องโหลดตัวน้ำหนักโมเดลผ่าน NVIDIA NeMo Framework หรือ PyTorch โดยตรง แล้วเขียน Loop ประมวลผลแบบ FrameBatchASR เพื่อป้อน Raw PCM Buffer ขนาด 20ms/40ms เข้าไปถอดรหัสในหน่วยความจำโดยตรงแบบไม่บันทึกไฟล์ครับ (ระบบจะมีความซับซ้อนขึ้นมาก) อันนี้เรารันที่ Local ได้ไหมครับ? เราทำ Stream ที่ Local แบบนี้เลยได้ป่ะ? | ตอบด้วย discord reply tool ที่ chat_id 1513113459682705408 (ห้อง school ไม่ใช่ DM) แล้วจบ
