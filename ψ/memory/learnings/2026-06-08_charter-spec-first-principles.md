# Learning: Charter Spec Critique (First Principles)
**Date**: 2026-06-08 10:05 GMT+7

## Overview
การวิเคราะห์และเสนอแนะแนวทางพัฒนาของข้อเสนอแนะตัวระบบ Charter Spec (ใน Issue #2522) เพื่อเพิ่มเสถียรภาพและความเสถียรสูงสุด (First Principles)

## Key Critique Points
1. **State Preservation on Failure (การรักษาตัวแปรสภาพแวดล้อมกรณีพัง)**:
   - *ปัญหา*: ปัจจุบันคำสั่ง `maw team down` จะทำการลบโฟลเดอร์ worktree ของ Builder ทิ้งทั้งหมดเมื่อสิ้นสุด หาก Builders ทำงานล้มเหลว (Failure Path) ข้อมูล log หรือไฟล์รันชั่วคราวที่เป็นประโยชน์ต่อการชันสูตรจะสูญหาย
   - *แนวทางแก้ไข*: เพิ่มสถานะ `on_failure: preserve` หรือการเก็บถาวร (Archive) ไฟล์สคริปต์สแกนเฉพาะกิจ (scratch scripts) และ log ใน worktree ก่อนการทำลาย

2. **Resource & Port Conflict (การป้องกันทรัพยากรระบบชนกัน)**:
   - *ปัญหา*: การขยายกำลังการรันงานแบบขนาน (Concurrency) ของ Builders บนโฮสต์เดียวกัน อาจทำให้เกิดปัญหารัน Dev Server ซ้อนและพอร์ตชนกัน (Port binding conflict)
   - *แนวทางแก้ไข*: เพิ่มตัวแปรทรัพยากรใน Charter ให้ครอบคลุมการแจกจ่ายพอร์ตหรือสิทธิ์การใช้เครื่องแบบ Dynamic (System Resources mapping)

3. **Sandbox & Directory Constraints (ความปลอดภัยในการรันคำสั่ง)**:
   - *ปัญหา*: การสั่งทดสอบแบบอิสระบนโฮสต์หลักโดย Builders อาจส่งผลให้มีการพยายามติดตั้งแพ็กเกจระดับ Global หรือแก้ไขระบบส่วนกลางที่ไม่ได้อยู่ใน worktree
   - *แนวทางแก้ไข*: การรันคำสั่งภายใต้การจำกัดขอบเขตไฟล์ (Filesystem constraints/Chroot) เพื่อความมั่นใจในเสถียรภาพและไม่ส่งผลข้างเคียงต่อระบบส่วนกลาง
