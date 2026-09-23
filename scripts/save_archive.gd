extends RefCounted
## Versioned, data-only envelope. RuntimeData retains fields added by future systems.
const VERSION:=2
const GROUPS={
 "PlayerData":["realm","cultivation","age","lifespan","spirit_stones","attempts","failures","rebirths","successes","biggest_gain","recent","history"],
 "ProgressData":["sect","tournament","festival_seen","festival_pending","array_attempts","activity_counters","duel_count","foundation_grade","foundation_seen"],
 "InventoryData":["materials","raw_stones","fragments","pills","upper_pills","tickets","blood_items","keepsakes","treasures"],
 "EventFlags":["unlock_notified","unlock_queue","help_seen","new_features","notified_rewards","first_rebirth_complete","foundation_unlock_granted","practice_completed"],
 "SettingsData":["settings_data"]}
static var blocked: Dictionary={}
static var status: Dictionary={}
static var last_digest: Dictionary={}
static func digest(bytes: PackedByteArray) -> String:
 var hash:=HashingContext.new();hash.start(HashingContext.HASH_SHA256);hash.update(bytes);return hash.finish().hex_encode()
static func pack(fields: Dictionary) -> Dictionary:
 var sections: Dictionary={"RuntimeData":fields.duplicate(true)}
 for group in GROUPS:
  sections[group]={}
  for key in GROUPS[group]:
   if fields.has(key): sections[group][key]=fields[key];sections.RuntimeData.erase(key)
 return sections
static func read(path: String) -> Dictionary:
 if not FileAccess.file_exists(path): return {"ok":false,"reason":"missing"}
 var file:=FileAccess.open(path,FileAccess.READ)
 if file==null or file.get_length()>32*1024*1024: return {"ok":false,"reason":"unreadable"}
 if file.get_length()<4: return {"ok":false,"reason":"truncated"}
 var length:=file.get_32()
 if length<=0 or length>file.get_length()-4: return {"ok":false,"reason":"truncated payload"}
 file.seek(0)
 var data: Variant=file.get_var(false)
 if not data is Dictionary: return {"ok":false,"reason":"invalid envelope"}
 if data.get("version",0)==1 and data.get("run") is Dictionary and data.run.get("fields") is Dictionary:
  return {"ok":true,"fields":data.run.fields,"version":1}
 if data.get("save_version",0)!=VERSION or data.get("magic","")!="RiskItOrDie": return {"ok":false,"reason":"unsupported version"}
 if not data.get("payload") is PackedByteArray: return {"ok":false,"reason":"invalid payload"}
 if digest(data.payload)!=data.get("checksum",""): return {"ok":false,"reason":"checksum mismatch"}
 var sections: Variant=bytes_to_var(data.payload)
 if not sections is Dictionary: return {"ok":false,"reason":"invalid sections"}
 var fields: Dictionary={}
 for group in sections:
  if not sections[group] is Dictionary: return {"ok":false,"reason":"invalid section"}
  fields.merge(sections[group],false)
 if fields.is_empty(): return {"ok":false,"reason":"empty save"}
 return {"ok":true,"fields":fields,"version":VERSION}
static func write(fields: Dictionary, path: String) -> bool:
 if blocked.get(path,false): status[path]="存档读取失败，原文件已保护；请先恢复备份或明确开始新游戏。";return false
 var payload:=var_to_bytes(pack(fields));var checksum:=digest(payload)
 if last_digest.get(path,"")==checksum and FileAccess.file_exists(path): return true
 var file:=FileAccess.open(path+".tmp",FileAccess.WRITE)
 if file==null: status[path]="无法写入临时存档。";return false
 file.store_var({"magic":"RiskItOrDie","save_version":VERSION,"saved_at":Time.get_datetime_string_from_system(true),"checksum":checksum,"payload":payload},false)
 file.flush();var error:=file.get_error();file.close()
 if error!=OK or not read(path+".tmp").ok: status[path]="临时存档校验失败，旧存档未改动。";return false
 if FileAccess.file_exists(path):
  if not read(path).ok: blocked[path]=true;status[path]="现有存档损坏，已停止覆盖。";return false
  if DirAccess.copy_absolute(path,path+".bak")!=OK: status[path]="备份失败，旧存档未改动。";return false
 var replaced:=DirAccess.rename_absolute(path+".tmp",path)
 if replaced!=OK: status[path]="替换存档失败，旧存档与临时文件已保留。";return false
 last_digest[path]=checksum;status[path]="保存成功";return true
static func load_fields(path: String) -> Dictionary:
 var result:=read(path)
 if result.ok: blocked.erase(path);status[path]="读取成功";return result
 if result.reason=="missing" and not FileAccess.file_exists(path+".bak"): status[path]="没有存档";return result
 blocked[path]=true
 var backup:=read(path+".bak")
 if backup.ok:
  status[path]="主存档不可读取，已从备份恢复；原文件保留，需确认修复后才能保存。"
  return backup
 status[path]="存档和备份均不可读取；原文件已保护，使用默认数据。"
 return result
static func reset(path: String) -> bool:
 # Explicit user action only: archive instead of destroying the previous run.
 var suffix:=".archived."+str(Time.get_unix_time_from_system()).replace(".","_")
 for extra in ["",".bak",".tmp"]:
  if FileAccess.file_exists(path+extra) and DirAccess.rename_absolute(path+extra,path+extra+suffix)!=OK: return false
 blocked.erase(path);last_digest.erase(path);status[path]="旧存档已归档";return true
