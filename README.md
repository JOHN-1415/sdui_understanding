# Server-Driven UI (SDUI) Testing & Experience Ecosystem
### Dual-Mode Admin Architecture • Node.js REST Backend • Dynamic Flutter Mobile Engine

---

## 🌟 Executive Architecture Overview

This project provides an end-to-end **Server-Driven UI (SDUI)** testbed where the mobile application's layout, widgets, order, and styling are rendered entirely from dynamic JSON schemas delivered over REST APIs, with zero app store releases required.

```
+-------------------------------------------------------------------------------+
|                             ADMIN PORTAL STATE                                |
|                                                                               |
|   +----------------------------+      +---------------------------------+     |
|   |  Mode A: Raw JSON Editor   | <--> |  Mode B: Visual Builder Canvas  |     |
|   |  (Upload / Drag / Validate)| Sync |  (Reorder, Palette, Inspector)  |     |
|   +----------------------------+      +---------------------------------+     |
+-------------------------------------------------------------------------------+
                                        |
                            [ Publish UI Schema ]
                                        v
                  +-------------------------------------------+
                  | Node.js Backend (POST /api/v1/screen/home)|
                  | Local disk storage: data/screens.json     |
                  +-------------------------------------------+
                                        |
                            [ Fetch Updated Schema ]
                                        v
                  +-------------------------------------------+
                  | Flutter Mobile App (SDUI Parsing Engine)  |
                  | Dynamic Rendering • In-App Admin Settings |
                  +-------------------------------------------+
```

---

## 📁 Project Directory Structure on `D:\`

All necessary files have been created in `D:\sdui_workspace\`:

```
D:\sdui_workspace\
├── backend\
│   ├── data\
│   │   └── screens.json            <-- Local disk JSON schema persistence
│   ├── public\
│   │   └── downloads\
│   │       └── sdui-app.apk        <-- Ready-to-download compiled Android APK
│   ├── server.js                   <-- Express REST API & static server
│   └── package.json
│
├── admin-portal\
│   ├── index.html                  <-- Dual-Mode Web Admin Interface
│   ├── styles.css                  <-- Modern dark glassmorphic styling
│   └── app.js                      <-- Bi-directional synchronization logic
│
└── flutter_app\
    ├── android\                    <-- Android config (INTERNET, cleartext)
    ├── build\app\outputs\flutter-apk\
    │   └── app-debug.apk           <-- Compiled debug APK (148 MB)
    ├── lib\
    │   ├── main.dart               <-- App entry point
    │   ├── models\
    │   │   └── sdui_models.dart    <-- Data classes & JSON deserialization
    │   ├── services\
    │   │   └── sdui_service.dart   <-- Network, cache, URL management
    │   ├── screens\
    │   │   ├── sdui_screen.dart    <-- Dynamic SDUI renderer with pull-to-refresh
    │   │   └── admin_config_dialog.dart <-- In-app admin & server settings
    │   └── widgets\
    │       ├── sdui_parser.dart    <-- Widget factory routing JSON -> Flutter
    │       └── sdui_action_handler.dart <-- Action handler (toast, dialog, copy)
    └── pubspec.yaml
```

---

## 🚀 Quick Start Guide

### 1. Launch the Backend Server & Admin Portal

Open PowerShell or Command Prompt:

```powershell
cd D:\sdui_workspace\backend
npm start
```

The server automatically starts on port `5000`:
- **Admin Portal**: Open [http://localhost:5000](http://localhost:5000) in your web browser.
- **Local Network Access**: `http://<your-computer-ip>:5000` (e.g. `http://10.129.222.211:5000`).
- **REST Screen API**: `http://localhost:5000/api/v1/screen/home`.
- **Direct APK Download**: `http://localhost:5000/api/v1/download-apk`.

---

### 2. Download and Run the Mobile App (Two Methods)

#### Method A: Direct APK Download onto your Android Phone (Recommended)
The Android APK has been pre-compiled and placed in the server's public download folder.

1. Ensure your Android phone is connected to the same Wi-Fi network as your PC.
2. Open Chrome or any browser on your Android phone.
3. Navigate to:
   ```
   http://<your-pc-ip>:5000/api/v1/download-apk
   ```
   *(You can find your computer's exact IP by clicking the "Get APK" or Settings icon in the Admin Portal header).*
4. Tap **Download**, open the downloaded `sdui-mobile-app.apk`, and tap **Install**.
5. Launch the installed **SDUI Mobile App** on your device.

#### Method B: Run from Source via Flutter CLI
To run on an emulator, connected device, or web:

```powershell
cd D:\sdui_workspace\flutter_app
flutter run
```

---

## 🎛️ Dual-Mode Admin Architecture Capabilities

The Admin Portal maintains a **single unified master state**. Changes made in any mode immediately update all other views in real time.

### 1. Mode A: Raw JSON Schema Upload & Editor
- **Direct Upload / Drag-and-Drop**: Drag any `.json` schema file onto the dropzone or click **Upload .json**.
- **Real-Time Syntax Validation**: Displays `Valid JSON` (green) or `Invalid JSON` (red with line error) as you type.
- **Snippet Toolbar**: Quick-insert buttons (`+ Banner`, `+ Service Grid`, `+ Promo Card`, `+ Product Card`, `+ Carousel`, `+ Chips`, `+ Search Bar`, `+ Button`) insert pre-configured valid widget schemas at your cursor.
- **Format & Minify**: One-click beautify with 2-space indentation.
- **Auto-Sync to Visual Canvas**: Valid JSON typed or pasted immediately re-renders the visual blocks and phone preview.

### 2. Mode B: Visual Component Arranger (Auto-JSON Generator)
- **Component Palette**: 10 widgets ready to add with a single click.
- **Visual Reorderable Hierarchy**:
  - Drag and drop cards using the drag handle `☰`.
  - Or click the `▲` / `▼` arrow controls to swap widget positions.
- **Property Inspector Drawer**:
  - Click **Edit** on any card to open the slide-over inspector.
  - Adjust titles, subtitles, image URLs, prices, discounts, and expiration times.
  - Pick background colors using hex inputs or quick-preset color chips.
  - Configure interactive actions (`toast`, `dialog`, `copy_code`, `navigate`).
  - Edit nested lists for chips, service items, and carousel cards.
- **Instant Compilation**: Every visual drag or form keystroke compiles into valid JSON schema.

### 3. Live Interactive Mobile Phone Simulator
- Right-hand panel displays a realistic smartphone viewport with notch, clock, battery bar, and scrollable canvas.
- Renders the exact visual appearance of all SDUI components.
- Interactive: Tapping items in the preview triggers the simulated action toast or alert dialog!

### 4. Publishing UI Schemas
- Click the **Publish UI Schema** button in the header.
- Sends `POST /api/v1/screen/home` to the local Node.js backend.
- Persisted directly to `backend/data/screens.json`.
- A success toast `🚀 UI Schema published!` confirms the update.

---

## 📱 In-App Admin Configurations (On Mobile)

The Flutter mobile application includes an **in-app Admin & Configuration Panel**:

### Accessing the In-App Admin Modal
- Tap the **Admin Config** floating button at the bottom right, OR
- Tap the **Settings icon** (`Icons.admin_panel_settings`) in the top app bar.

### Features inside the Mobile App:
1. **Change Backend Server IP / URL**:
   - Change the API URL on the fly without recompiling the app.
   - Quick Host Presets:
     - `Emulator (10.0.2.2)`: For standard Android Studio emulators.
     - `WiFi IP (10.129.222.211)`: For physical phones on your home/office Wi-Fi.
     - `Localhost`: For local desktop/web runs.
2. **Live Connection Test (Ping)**:
   - Tap the antenna icon to test server reachability.
   - Shows latency in milliseconds (e.g., `Connected to SDUI Server (24ms)`).
   - Automatically displays all network IPs detected by the backend.
3. **Screen Switcher**:
   - Seamlessly switch between `home` and `explore` screens.
4. **Live In-App Raw JSON Schema Editor**:
   - An expandable code editor right on your phone!
   - Paste or modify JSON directly on mobile and tap **Apply Schema Live** to immediately test layouts offline.
5. **Local Storage Persistence**:
   - Settings are saved to `SharedPreferences` so your server URL is remembered across app restarts.
6. **Pull-to-Refresh**:
   - Swipe down from the top of the mobile screen anytime to fetch the latest schema published from the web Admin Portal!

---

## 🧩 Supported SDUI Component Specification

Each component in the schema adheres to this structure:

```json
{
  "id": "comp_unique_id",
  "type": "banner",
  "props": { ... },
  "action": {
    "type": "dialog",
    "payload": {
      "title": "Alert Title",
      "message": "Alert Message"
    }
  },
  "styles": {
    "backgroundColor": "#4F46E5",
    "textColor": "#FFFFFF",
    "borderRadius": 16,
    "margin": [8, 16, 12, 16]
  }
}
```

### Supported Widget Types:
| Component Type | Description | Key Properties |
|---|---|---|
| `search_bar` | Rounded search input container | `placeholder`, `showFilter` |
| `banner` | Hero promotional card with image/gradient | `title`, `subtitle`, `badge`, `ctaText`, `imageUrl` |
| `category_chips` | Horizontal scrollable filter pills | `items` (array of strings), `selectedIndex` |
| `section_title` | Section header with optional link | `title`, `subtitle`, `actionText` |
| `service_grid` | 2, 3, or 4 column grid of services | `columns`, `items` (title, icon, badge, action) |
| `promo_card` | Ticket-style discount voucher | `title`, `discount`, `code`, `description`, `expires` |
| `product_card` | E-commerce product showcase | `title`, `description`, `price`, `originalPrice`, `rating`, `imageUrl`, `tag` |
| `carousel` | Horizontal image card slider | `items` (title, subtitle, imageUrl, tag) |
| `button_action` | Full-width interactive CTA button | `text`, `variant` (`primary`, `secondary`, `outline`) |
| `spacer` | Vertical layout spacing | `height` (pixels) |

### Supported Action Types:
- `toast`: Displays a modern floating notification banner on screen.
- `dialog`: Displays an alert dialog modal with title, message, and dismiss button.
- `copy_code`: Automatically copies a coupon code to the system clipboard.
- `navigate`: Navigates to a target screen ID.

---

## 🛠️ Rebuilding the APK (If You Make Code Changes)

If you modify the Flutter source code and want to recompile the APK:

```powershell
cd D:\sdui_workspace\flutter_app
flutter build apk --debug
Copy-Item build\app\outputs\flutter-apk\app-debug.apk ..\backend\public\downloads\sdui-app.apk -Force
```

The new APK will immediately be available at `http://<your-pc-ip>:5000/api/v1/download-apk`!
