# SeniorCare – Frontend to Backend Feature Mapping & Integration Blueprint
**Phase 1 Deliverable | Role: Person 2 (Integration Architect & Backend Lead)**
**Primary Frontend Reference:** Person 1's Flutter Implementation (`Elder-App/lib/main.dart`)

---

## 1. Inspection Report of Person 1's Existing Codebase

During the initial codebase inspection of `D:\Elder Seva app\Elder-App`, the following components, assets, and design patterns were identified:

1. **Current Flutter Entrypoint & App Configuration:**
   - Class: `ElderlySevaApp` ([`lib/main.dart`](file:///d:/Elder%20Seva%20app/Elder-App/lib/main.dart))
   - Theme: Material 3 enabled, Roboto typography, custom senior-friendly pastel palette (`#F1F7FF` background, `#102B58` navy text, `#3E91F2` blue primary, `#FF5555` coral emergency).
   - Active Initial Route: `HomeDashboard` (Senior Citizen primary view).
2. **Local Assets Present:**
   - `assets/images/dadaji_profile.png` (Senior circular avatar)
   - `assets/images/family_illustration.png` (My Family card banner)
   - `assets/images/medicine_illustration.png` (My Medicines card banner)
   - `assets/images/doctor_illustration.png` (Healthcare consultation asset)
3. **Current State of Interactivity:**
   - All interactive cards trigger SnackBar placeholders (e.g., `showMessage(context, 'Settings coming soon!')`) or a demo alert dialog on the SOS card.
   - Person 1 has laid out the complete visual wireframe and component hierarchy for Phase 1. 
   - Person 2's role is to ensure every UI element connects seamlessly to a robust backend API in Phase 2.

---

## 2. Comprehensive Screen & Component Mapping

Below is the exhaustive mapping connecting every visual element in Person 1's `main.dart` to the corresponding backend contracts.

---

### Component 1: `HeaderSection` (Senior Profile & Greeting)

* **Flutter Code Reference:** `HeaderSection` ([`lib/main.dart#L179-L252`](file:///d:/Elder%20Seva%20app/Elder-App/lib/main.dart#L179-L252))
* **Target User Role:** `senior`
* **UI Elements:**
  * Circular avatar (`dadaji_profile.png`)
  * Heading text (`"नमस्ते दादाजी"`)
  * Subtitle text (`"Take care and stay healthy!"`)
  * Settings icon button (`Icons.settings_rounded`)
* **Backend API Endpoint:**
  * `GET /api/v1/healthcare/seniors/{senior_id}/dashboard-summary`
* **Data Fields Returned by Backend:**
  ```json
  {
    "senior_name": "Ramesh Sharma",
    "preferred_name": "दादाजी",
    "greeting": "नमस्ते दादाजी",
    "subtitle": "Take care and stay healthy!",
    "profile_picture_url": "https://api.seniorcare.health/assets/seniors/avatar-1.png",
    "unread_notifications": 2
  }
  ```
* **User Actions:**
  * Tap Settings $\rightarrow$ Navigate to `SettingsScreen` (Language selection, Emergency contacts, Biometric Face Re-enrollment, Logout).
* **Required Permissions:** Authenticated `senior` accessing their own profile.

---

### Component 2: `ImageServiceCard` – "My Family"

* **Flutter Code Reference:** `ImageServiceCard` ([`lib/main.dart#L71-L77`](file:///d:/Elder%20Seva%20app/Elder-App/lib/main.dart#L71-L77))
* **Target User Role:** `senior`
* **Card Details:** Title: "My Family", Subtitle: "Your loved ones always with you", Asset: `family_illustration.png`.
* **Backend API Endpoints:**
  * `GET /api/v1/family/seniors/{senior_id}/circle` (List connected family members)
  * `GET /api/v1/family/updates/moments` (Timeline of shared photos and greeting messages from children)
* **Data Fields Expected by Frontend:**
  ```json
  {
    "connected_members": [
      {
        "id": "rel-uuid-1",
        "name": "Priya Sharma",
        "relation": "Daughter",
        "phone": "+919811223344",
        "is_primary": true,
        "avatar_url": "https://api.seniorcare.health/avatars/priya.jpg"
      }
    ],
    "recent_moments": [
      {
        "id": "moment-uuid-1",
        "author_name": "Priya (Daughter)",
        "caption": "Good morning Dadaji! Hope you took your morning walk.",
        "photo_url": "https://api.seniorcare.health/photos/morning-walk.jpg",
        "created_at": "2026-11-06T07:15:00Z"
      }
    ]
  }
  ```
* **User Actions:**
  * View care circle members.
  * Tap "Invite Family Member" $\rightarrow$ triggers `POST /api/v1/family/invitations`.
  * Tap "Call Daughter" $\rightarrow$ direct phone intent.

---

### Component 3: `ImageServiceCard` – "My Medicines"

* **Flutter Code Reference:** `ImageServiceCard` ([`lib/main.dart#L79-L86`](file:///d:/Elder%20Seva%20app/Elder-App/lib/main.dart#L79-L86))
* **Target User Role:** `senior`
* **Card Details:** Title: "My Medicines", Subtitle: "Track your medicines and timings", Asset: `medicine_illustration.png`.
* **Backend API Endpoints:**
  * `GET /api/v1/healthcare/seniors/{senior_id}/medicines` (Active medicines & today's schedule)
  * `POST /api/v1/healthcare/medicines/logs` (Log dose as Taken / Snoozed / Missed)
* **Data Fields Expected by Frontend:**
  ```json
  {
    "today_doses": [
      {
        "schedule_id": "sched-uuid-101",
        "medicine_name": "Metformin",
        "strength": "500mg",
        "time_of_day": "14:00:00",
        "meal_relation": "after_meal",
        "instructions": "खाने के बाद पानी के साथ लें",
        "status": "pending"
      }
    ]
  }
  ```
* **User Actions:**
  * Tap "Mark Taken" $\rightarrow$ Submits `POST /api/v1/healthcare/medicines/logs` with `status: 'taken'`.
  * Tap "Snooze 15 mins" $\rightarrow$ Re-queues local push notification.
* **Required Permissions:** `senior` or `family` with `medicines:view_only` or `medicines:full_management`.

---

### Component 4: `SmallServiceCard` – "Health Tracker"

* **Flutter Code Reference:** `SmallServiceCard` ([`lib/main.dart#L96-L103`](file:///d:/Elder%20Seva%20app/Elder-App/lib/main.dart#L96-L103))
* **Target User Role:** `senior` / `family`
* **Card Details:** Title: "Health Tracker", Subtitle: "Monitor your health easily", Icon: `Icons.favorite_rounded`.
* **Backend API Endpoints:**
  * `GET /api/v1/healthcare/seniors/{senior_id}/records?record_type=vitals` (Historical graph data)
  * `POST /api/v1/healthcare/seniors/{senior_id}/records` (Log new BP or Blood Glucose)
* **Data Fields Expected by Frontend:**
  ```json
  {
    "latest_vitals": {
      "blood_pressure": "122/80 mmHg",
      "blood_glucose": "114 mg/dL",
      "heart_rate": "72 bpm",
      "last_recorded_at": "2026-11-06T08:00:00Z"
    },
    "trend_7_days": [
      {"date": "2026-11-01", "systolic": 120, "diastolic": 78},
      {"date": "2026-11-02", "systolic": 124, "diastolic": 82}
    ]
  }
  ```
* **User Actions:**
  * View vitals graph over time.
  * Tap "Add Reading" $\rightarrow$ Input dialogue for Blood Pressure and Sugar.

---

### Component 5: `SmallServiceCard` – "Talk to a Doctor"

* **Flutter Code Reference:** `SmallServiceCard` ([`lib/main.dart#L105-L113`](file:///d:/Elder%20Seva%20app/Elder-App/lib/main.dart#L105-L113))
* **Target User Role:** `senior` / `family`
* **Card Details:** Title: "Talk to a Doctor", Subtitle: "Get medical help anytime", Icon: `Icons.medical_services_rounded`.
* **Backend API Endpoints:**
  * `GET /api/v1/consultations/doctors` (List available geriatricians & physicians)
  * `POST /api/v1/consultations/appointments` (Book video or clinic consultation)
* **Data Fields Expected by Frontend:**
  * List of doctors: name, qualification, fee, next available slot, rating.
* **User Actions:**
  * Tap "Join Video Call" when slot is active $\rightarrow$ Launches WebRTC consultation room.

---

### Component 6: `MoreServiceCard` – "Book a Caregiver"

* **Flutter Code Reference:** `MoreServiceCard` ([`lib/main.dart#L133-L140`](file:///d:/Elder%20Seva%20app/Elder-App#L133-L140))
* **Target User Role:** `senior` / `family`
* **Card Details:** Title: "Book a Caregiver", Subtitle: "Trusted daily assistance", Icon: `Icons.volunteer_activism_rounded`.
* **Backend API Endpoints:**
  * `GET /api/v1/caregivers/search?city={city}` (Catalog of certified caregivers)
  * `POST /api/v1/caregivers/bookings` (Request shift booking)
  * `GET /api/v1/caregivers/bookings/{booking_id}/visit-report` (View caregiver shift report)
* **Data Fields Expected by Frontend:**
  * Caregiver cards: name, experience, hourly rate, verified badges, rating, customer reviews.

---

### Component 7: `MoreServiceCard` – "Nearby Hospitals"

* **Flutter Code Reference:** `MoreServiceCard` ([`lib/main.dart#L143-L150`](file:///d:/Elder%20Seva%20app/Elder-App#L143-L150))
* **Target User Role:** `senior` / `family`
* **Card Details:** Title: "Nearby Hospitals", Subtitle: "Find medical help nearby", Icon: `Icons.local_hospital_rounded`.
* **Backend API Endpoints:**
  * `GET /api/v1/consultations/nearby-hospitals?latitude={lat}&longitude={lng}`
* **Data Fields Expected by Frontend:**
  * Hospital name, distance in kilometers, 24/7 emergency helpline number, ambulance direct call button.
* **User Actions:**
  * One-tap phone dialer to call hospital ambulance.
  * Tap "Directions" $\rightarrow$ Opens Google Maps navigation.

---

### Component 8: `SOSCard` (Emergency Distress Trigger)

* **Flutter Code Reference:** `SOSCard` ([`lib/main.dart#L493-L572`](file:///d:/Elder%20Seva%20app/Elder-App#L493-L572))
* **Target User Role:** `senior`
* **Card Details:** Prominent coral card (`#FF5555`), warning icon, "SOS", "Emergency? Tap here for help".
* **Backend API Endpoints:**
  * `POST /api/v1/emergency/sos` (High-priority distress creation)
  * `POST /api/v1/emergency/sos/{event_id}/resolve` (Close incident)
* **Payload Dispatched to Backend:**
  ```json
  {
    "latitude": 26.9124,
    "longitude": 75.7873,
    "trigger_source": "in_app_button",
    "battery_level_percent": 84
  }
  ```
* **Backend Execution SLA:**
  * Response $< 800\text{ ms}$; Celery concurrently dispatches FCM high-priority siren pushes and Twilio SMS with live GPS tracking links.
* **User Actions:**
  * Senior taps SOS $\rightarrow$ Vibrates with 5-second cancel countdown $\rightarrow$ Broadcasts alert.
  * Active screen displays: *"Help is on the way! Your family and emergency contacts have been notified."*

---

### Component 9: `VoiceAssistantCard` – "Ask Me Anything"

* **Flutter Code Reference:** `VoiceAssistantCard` ([`lib/main.dart#L576-L648`](file:///d:/Elder%20Seva%20app/Elder-App#L576-L648))
* **Target User Role:** `senior`
* **Card Details:** Mint card (`#DDF8E6`), microphone button, graphic equalizer, "Ask Me Anything - Your Voice Assistant".
* **Backend API Endpoints:**
  * `POST /api/v1/assistant/chat` (LangGraph stateful conversational engine with RAG)
* **Data Fields Exchanged:**
  * Senior voice query (speech-to-text string in Hindi/English) $\rightarrow$ Returns structured answer text + pre-rendered TTS audio streaming URL.
* **Safety Integration:** If the senior says *"मुझे चक्कर आ रहे हैं"* (I feel dizzy) or *"मैं गिर गया हूँ"* (I have fallen), the assistant automatically triggers the Emergency SOS workflow.

---

### Component 10: `BottomNavigation` (Core App Navigation Tabs)

* **Flutter Code Reference:** `BottomNavigation` ([`lib/main.dart#L652-L734`](file:///d:/Elder%20Seva%20app/Elder-App#L652-L734))
* **Tabs:**
  1. **Home (`Icons.home_rounded`):** Currently displays `HomeDashboard`.
  2. **Reminders (`Icons.calendar_month_rounded`):**
     * Backend Endpoint: `GET /api/v1/healthcare/seniors/{senior_id}/medicines`
     * Purpose: Full day timeline of morning, afternoon, and evening medicine doses.
  3. **Insights (`Icons.bar_chart_rounded`):**
     * Backend Endpoint: `GET /api/v1/healthcare/seniors/{senior_id}/records/insights`
     * Purpose: Weekly medicine adherence score (e.g., 94%), average blood pressure, activity summary.
  4. **More (`Icons.grid_view_rounded`):**
     * Backend Endpoint: `GET /api/v1/users/me`
     * Purpose: Caregiver booking history, family care circle settings, lab bookings, subscription management, logout.

---

## 3. Recommended Frontend Additions for Person 1 (Phase 2 Roadmap)

To seamlessly connect the frontend to the backend without altering Person 1's existing work, the following screens and input fields should be planned for Person 1 in Phase 2:

| Planned Screen | Recommended Route | Key Input Fields & UI Needs |
| :--- | :--- | :--- |
| **Authentication Screen** | `/auth/login` | Mobile number field, "Get OTP" button, "Face Login" button. |
| **Face Enrollment Screen**| `/auth/face-enroll`| Camera preview circle with real-time prompt text (*"Please blink once"*). |
| **Family Circle Screen** | `/family/circle` | Connected member cards, "+ Invite Family Member" modal with phone input. |
| **Medicine Detail Screen**| `/medicines/detail`| High-contrast "Taken" (Green) and "Snooze 15m" (Yellow) buttons. |
| **Caregiver Detail Screen**| `/caregivers/profile`| Profile photo, verified badges (Police verified, Nursing certified), booking form. |
| **SOS Active Screen** | `/emergency/active`| Full-screen red visual alert with 5-second cancel timer and live dispatch map. |
| **Role Selector / Profile Switcher** | Drawer / Top bar | For family members caring for multiple seniors, a top dropdown to switch between Dadaji and Naniji. |

