# HAOS & Oracle Fleet Architecture Manual (คู่มือพิมพ์เขียวระบบ HAOS)

> **Host ประจำการหลัก**: ClubSGame (AMD Ryzen 7 7840U / Hyper-V VM / IP: `100.87.51.122`)  
> **สถานะระบบปัจจุบัน**: HAOS Core `2026.9.4` · Arra Memory `0.27.1` (Embedding: `bge-m3`) · Mosquitto MQTT `1883`

---

## 1. บทบาทและสถาปัตยกรรมของ HAOS ในฝูง Oracle
Home Assistant OS (HAOS) ถูกยกระดับจากการควบคุมบ้านอัจฉริยะ ให้เป็น **ศูนย์กลางโครงสร้างพื้นฐานกลาง (Central Infrastructure Backbone)** ของ Oracle Council ทำหน้าที่ 4 เสาหลัก:
1. **MQTT Fleet Bus (Mosquitto Broker)**: ท่อสื่อสารกลางแบบ Pub/Sub สำหรับ Agent ทุกตัว
2. **Arra Fleet Memory**: ฐานความจำถาวรแบบ Semantic Search (Embedding: `bge-m3` / libSQL) ผ่านโปรโตคอล MCP
3. **Oracle Registry (LWT Inventory)**: ทะเบียนเฝ้าดูสถานะว่า Agent ตัวไหนออนไลน์/ออฟไลน์ ด้วยกลไก Last Will and Testament
4. **Tailscale Mesh Gateway**: เชื่อมโยงเครือข่ายปลอดภัยข้ามโฮสต์ (MacLab, ClubSGame, WSL2, VPS)

---

## 2. รายการ Add-ons หลักที่ HAOS ต้องติดตั้ง (The 4 Core Pillars)

| ลำดับ | ชื่อ Add-on | แหล่งที่มา (Repository) | พอร์ตใช้งาน | หน้าที่ |
|:---:|---|---|:---:|---|
| **1** | **Mosquitto broker** | Official HAOS Add-on Store | `1883` | เมสเสจบัสกลาง, LWT, ท่อกระจายคำสั่งข้ามโฮสต์ |
| **2** | **Tailscale** | Official HAOS Add-on Store | VPN | เชื่อมต่อเข้า Tailnet วง `100.x.x.x` |
| **3** | **Arra Memory** | `https://github.com/Soul-Brews-Studio/arra-memory-haos` | `8099` | ฐานความจำกลาง + MCP Server (`/mcp`) |
| **4** | **Oracle Registry** | `https://github.com/Soul-Brews-Studio/oracle-registry-haos` | Ingress | ทะเบียนตรวจจับความมีชีวิตของ Agent แต่ละตัว |

---

## 3. การตั้งค่า PortProxy บน Windows Host (ClubSGame)
เนื่องจาก HAOS รันอยู่บน Hyper-V VM (Default Switch) ระบบ Windows ของ ClubSGame จึงต้องทำ Port Forwarding ผ่าน `netsh interface portproxy` เพื่อให้ Agent บน Windows, WSL2 และเครือข่ายภายนอกเข้าถึงได้:

```powershell
# รันด้วยสิทธิ์ Administrator บน ClubSGame
# แมปพอร์ตจาก VM (172.20.240.x) สู่ Host (0.0.0.0 หรือ 127.0.0.1 / 100.87.51.122)
netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=8123 connectaddress=<VM_IP>
netsh interface portproxy add v4tov4 listenport=1883 listenaddress=0.0.0.0 connectport=1883 connectaddress=<VM_IP>
netsh interface portproxy add v4tov4 listenport=8099 listenaddress=0.0.0.0 connectport=8099 connectaddress=<VM_IP>
```

---

## 4. การตั้งค่า Agent เพื่อเชื่อมต่อ HAOS

### 4.1 การตั้งค่า `.mcp.json` สำหรับ Arra Memory
สำหรับ Agent ทุกตัว (Claude CLI, Antigravity CLI `agy`, Grok) ให้เพิ่ม config ใน `.mcp.json`:

```json
{
  "mcpServers": {
    "arra-memory": {
      "type": "http",
      "url": "http://127.0.0.1:8099/mcp",
      "headers": {
        "Authorization": "Bearer bf9e86e0f371b0eeabf11de20677cb34b38abfec7113a10be8ffb4981965da14"
      }
    },
    "maclab-arra-memory": {
      "type": "http",
      "url": "http://100.83.0.1:8099/mcp",
      "headers": {
        "Authorization": "Bearer bf9e86e0f371b0eeabf11de20677cb34b38abfec7113a10be8ffb4981965da14"
      }
    }
  }
}
```

### 4.2 การลงทะเบียน MQTT LWT และสถานะความมีชีวิต
Agent แต่ละตัวต้องส่ง Heartbeat และผูก LWT เข้ากับ Mosquitto (`1883`):
* **Topic รายงานสถานะ**: `oracle/<agent_name>/meta` (Retained JSON: `{ "status": "online", "model": "...", "host": "..." }`)
* **Topic LWT (ตัดเมื่อหลุด)**: `oracle/<agent_name>/lwt` (Payload: `offline`, QoS 1, Retain: true)
* **Topic สื่อสารในฝูง**: `oracle/channel/<channel_name>`

---

## 5. คำสั่งตรวจสอบระบบ (Verification Commands)

```bash
# 1. ตรวจสอบสถานะ Core และ Arra Memory ผ่าน No.10 CLI
rtk haos status

# 2. ดูอัปเดตและ Add-ons ในระบบ
rtk haos list update

# 3. ค้นหาความจำใน Arra Memory
rtk haos memory search "คำค้นหา"

# 4. ทดสอบบันทึกความจำขึ้น HAOS
rtk haos memory remember "หัวข้อความจำ" "เนื้อหาข้อความ"
```

---

## 6. สรุปสิ่งที่ขาดไปและแนวทางแก้ไข (Gap Analysis)
1. **ขาดคู่มือรวมศูนย์**: เดิมทีแต่ละโฮสต์ตั้งค่ากระจัดกระจาย ไม่ได้ระบุพอร์ตชัดเจน ทำให้ Agent ชี้ไปพอร์ตเก่าที่ปิดไปแล้ว (เช่น พอร์ต `47778`) -> **แก้ไขโดยใช้เอกสารนี้เป็น Single Source of Truth**
2. **การซิงค์ความจำ 2 บ้าน**: ระหว่าง MacLab (`100.83.0.1`) กับ ClubSGame (`100.87.51.122`) ต้องตั้ง Cron รัน `arra-edge-sync` ทุก 15-30 นาทีเพื่อให้ความจำทั้งสองฝั่งเท่ากันเสมอ
3. **การบังคับใช้ MQTT Bus**: เปลี่ยนท่อการสั่งงานจาก P2P `maw hey` มาเป็นการ Publish เข้า MQTT Topic บน HAOS จะช่วยแก้ปัญหาข้อความหลุดและเชื่อมต่อไม่ติดได้อย่างถาวร
