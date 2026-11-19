import requests, time

BASE = 'http://127.0.0.1:8000/api/v1'

def check(step, condition, msg):
    status = 'PASS' if condition else 'FAIL'
    print(f'[{status}] {step}: {msg}')

ts = int(time.time()) % 100000

# --- 1. Senior Registration & Login ---
snr_phone = f'99999{ts:05d}'
res = requests.post(f'{BASE}/auth/register/senior', json={
    'fullName': f'Senior User {ts}',
    'phoneNumber': snr_phone,
    'password': 'password123',
    'preferredName': 'दादाजी',
    'gender': 'male',
    'city': 'Jaipur'
})
check('1.1 Senior Registration', res.status_code in (200, 201), f'Phone {snr_phone} registered: Status {res.status_code}')

res_snr_login = requests.post(f'{BASE}/auth/login', json={
    'emailOrPhone': snr_phone,
    'password': 'password123',
    'role': 'senior',
    'deviceUuid': 'flutter-web-chrome'
})
check('1.2 Senior Login', res_snr_login.status_code == 200, f'Status {res_snr_login.status_code}')
snr_token = res_snr_login.json().get('data', {}).get('access_token') if res_snr_login.status_code == 200 else ''
snr_headers = {'Authorization': f'Bearer {snr_token}'} if snr_token else {}

# --- 2. Family Registration & Login ---
fam_phone = f'88888{ts:05d}'
res = requests.post(f'{BASE}/auth/register/family', json={
    'fullName': f'Family Member {ts}',
    'phoneNumber': fam_phone,
    'password': 'password123',
    'relationshipType': 'daughter'
})
check('2.1 Family Registration', res.status_code in (200, 201), f'Phone {fam_phone} registered: Status {res.status_code}')

res_fam_login = requests.post(f'{BASE}/auth/login', json={
    'emailOrPhone': fam_phone,
    'password': 'password123',
    'role': 'family',
    'deviceUuid': 'flutter-web-chrome'
})
check('2.2 Family Login', res_fam_login.status_code == 200, f'Status {res_fam_login.status_code}')
fam_token = res_fam_login.json().get('data', {}).get('access_token') if res_fam_login.status_code == 200 else ''
fam_headers = {'Authorization': f'Bearer {fam_token}'} if fam_token else {}

# --- 3. Caregiver Registration & Login ---
cg_phone = f'77777{ts:05d}'
res = requests.post(f'{BASE}/auth/register/caregiver', json={
    'fullName': f'Caregiver {ts}',
    'phoneNumber': cg_phone,
    'password': 'password123',
    'serviceCity': 'Jaipur',
    'experienceYears': 4,
    'hourlyRate': 300.0
})
check('3.1 Caregiver Registration', res.status_code in (200, 201), f'Phone {cg_phone} registered: Status {res.status_code}')

res_cg_login = requests.post(f'{BASE}/auth/login', json={
    'emailOrPhone': cg_phone,
    'password': 'password123',
    'role': 'caregiver',
    'deviceUuid': 'flutter-web-chrome'
})
check('3.2 Caregiver Login', res_cg_login.status_code == 200, f'Status {res_cg_login.status_code}')

# --- 4. PostgreSQL Real Data Queries ---
res = requests.get(f'{BASE}/healthcare/seniors/056dd8f0-8fb6-47e7-871c-b1fafc6e2a89/dashboard-summary', headers=snr_headers)
snr_name = res.json().get('senior_name') if res.status_code == 200 else 'None'
greeting = res.json().get('greeting') if res.status_code == 200 else 'None'
check('4.1 Senior Dashboard Summary', res.status_code == 200, f'{snr_name} | {greeting}')

res = requests.get(f'{BASE}/healthcare/seniors/056dd8f0-8fb6-47e7-871c-b1fafc6e2a89/medicines', headers=snr_headers)
meds_count = len(res.json().get('medicines', [])) if res.status_code == 200 else 0
check('4.2 Senior Medicines', res.status_code == 200 and meds_count > 0, f'{meds_count} medications retrieved')

res = requests.get(f'{BASE}/healthcare/seniors/056dd8f0-8fb6-47e7-871c-b1fafc6e2a89/records', headers=snr_headers)
records_count = len(res.json().get('items', [])) if res.status_code == 200 else 0
check('4.3 Senior Health Records', res.status_code == 200, f'{records_count} vitals records')

# --- 5. Family Linking Workflow ---
res_invite = requests.post(f'{BASE}/family/invite', json={
    'targetPhone': snr_phone,
    'relationship': 'daughter'
}, headers=fam_headers)
inv_data = res_invite.json().get('data', {}) if res_invite.status_code in (200, 201) else {}
inv_code = inv_data.get('invitationCode')
inv_id = inv_data.get('invitationId')
check('5.1 Family Invite Creation', res_invite.status_code in (200, 201), f'Code: {inv_code}')

if inv_id:
    res_appr = requests.post(f'{BASE}/family/link/approve', json={
        'invitationId': inv_id,
        'approved': True
    }, headers=snr_headers)
    appr_msg = res_appr.json().get('message') if res_appr.status_code == 200 else res_appr.text
    check('5.2 Senior Approves Link', res_appr.status_code == 200, f'{appr_msg}')

# --- 6. Emergency SOS Dispatch & Resolution ---
res_sos = requests.post(f'{BASE}/emergency/sos', json={
    'latitude': 26.9124,
    'longitude': 75.7873,
    'trigger_source': 'in_app_button'
}, headers=snr_headers)
sos_status = res_sos.json().get('status') if res_sos.status_code == 201 else 'error'
event_id = res_sos.json().get('sos_event_id')
check('6.1 SOS Trigger', res_sos.status_code == 201, f'Status: {sos_status}')

if event_id:
    res_res = requests.post(f'{BASE}/emergency/sos/{event_id}/resolve', json={
        'resolution_status': 'resolved',
        'resolution_notes': 'Family responded'
    }, headers=snr_headers)
    res_msg = res_res.json().get('message') if res_res.status_code == 200 else res_res.text
    check('6.2 SOS Resolve', res_res.status_code == 200, f'{res_msg}')

# --- 7. RAM AI Assistant Interaction ---
res_ai = requests.post(f'{BASE}/assistant/chat', json={
    'message': 'मेरी अगली दवाई कब है?',
    'language': 'hi'
}, headers=snr_headers)
reply = res_ai.json().get('reply_text') if res_ai.status_code == 200 else res_ai.text
check('7.1 AI Chat Assistant', res_ai.status_code == 200, f'{reply}')

# --- 8. Consultations & Caregivers ---
res_cg_srch = requests.get(f'{BASE}/caregivers/search?city=Jaipur', headers=snr_headers)
cg_count = len(res_cg_srch.json().get('caregivers', [])) if res_cg_srch.status_code == 200 else 0
check('8.1 Caregiver Search', res_cg_srch.status_code == 200, f'{cg_count} caregivers found')

res_hosp = requests.get(f'{BASE}/consultations/nearby-hospitals', headers=snr_headers)
hosp_count = len(res_hosp.json().get('hospitals', [])) if res_hosp.status_code == 200 else 0
check('8.2 Nearby Hospitals', res_hosp.status_code == 200, f'{hosp_count} hospitals found')

res_docs = requests.get(f'{BASE}/consultations/doctors', headers=snr_headers)
doc_count = len(res_docs.json().get('doctors', [])) if res_docs.status_code == 200 else 0
check('8.3 Doctors Consultation', res_docs.status_code == 200, f'{doc_count} doctors found')

# --- 9. Session Logout ---
res_out = requests.post(f'{BASE}/auth/logout', json={'refreshToken': 'sample-refresh'}, headers=snr_headers)
check('9.1 Logout Handling', res_out.status_code == 200, 'User logged out and session cleared')
