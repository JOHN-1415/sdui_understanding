const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const morgan = require('morgan');
const fs = require('fs');
const path = require('path');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 5000;
const DATA_FILE = path.join(__dirname, 'data', 'screens.json');
const APK_LOCAL_PATH = path.join(__dirname, 'public', 'downloads', 'sdui-app.apk');
const APK_BUILD_PATH = path.join(__dirname, '..', 'flutter_app', 'build', 'app', 'outputs', 'flutter-apk', 'app-debug.apk');

// Middleware
app.use(cors());
app.use(morgan('dev'));
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '50mb' }));

// Serve static admin portal
const adminPortalPath = path.join(__dirname, '..', 'admin-portal');
app.use(express.static(adminPortalPath));
app.use('/public', express.static(path.join(__dirname, 'public')));

// Helper to get local IPv4 addresses
function getLocalIps() {
  const interfaces = os.networkInterfaces();
  const ips = [];
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        ips.push(iface.address);
      }
    }
  }
  return ips;
}

// Helper to read screens
function readScreens() {
  try {
    if (!fs.existsSync(DATA_FILE)) {
      return {};
    }
    const raw = fs.readFileSync(DATA_FILE, 'utf8');
    return JSON.parse(raw);
  } catch (err) {
    console.error('Error reading screens.json:', err);
    return {};
  }
}

// Helper to write screens
function writeScreens(data) {
  try {
    fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2), 'utf8');
    return true;
  } catch (err) {
    console.error('Error writing screens.json:', err);
    return false;
  }
}

// Default factory templates for reset
const DEFAULT_SCHEMAS = {
  home: {
    screenId: 'home',
    title: 'SDUI Dynamic Store',
    version: '1.0.0',
    updatedAt: new Date().toISOString(),
    theme: {
      primaryColor: '#6366F1',
      backgroundColor: '#0F172A',
      surfaceColor: '#1E293B',
      textColor: '#F8FAFC',
      accentColor: '#10B981'
    },
    components: [
      {
        id: 'comp_search_1',
        type: 'search_bar',
        props: {
          placeholder: 'Search 10,000+ items, services & offers...',
          showFilter: true
        },
        action: {
          type: 'toast',
          payload: { message: 'Search filter tapped' }
        },
        styles: { margin: [12, 16, 8, 16] }
      },
      {
        id: 'comp_banner_1',
        type: 'banner',
        props: {
          badge: '⚡ LIMITED TIME FLASH DEAL',
          title: 'Super Weekend Carnival',
          subtitle: 'Get up to 55% OFF on premium gadgets, audio gear & smart accessories.',
          imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&q=80',
          ctaText: 'Claim Discount'
        },
        action: {
          type: 'dialog',
          payload: {
            title: 'Promo Claimed 🎉',
            message: 'Coupon FLASH55 applied! Extra 10% cashback added to your SDUI wallet.'
          }
        },
        styles: {
          backgroundColor: '#4F46E5',
          textColor: '#FFFFFF',
          borderRadius: 16,
          margin: [8, 16, 12, 16]
        }
      },
      {
        id: 'comp_chips_1',
        type: 'category_chips',
        props: {
          selectedIndex: 0,
          items: [
            '🔥 All Deals',
            '💻 Electronics',
            '🛠️ Services',
            '👟 Fashion',
            '🛋️ Home Décor',
            '✨ Gadgets'
          ]
        },
        action: {
          type: 'toast',
          payload: { message: 'Category selected' }
        },
        styles: { margin: [4, 16, 12, 16] }
      },
      {
        id: 'comp_section_services',
        type: 'section_title',
        props: {
          title: 'Popular On-Demand Services',
          subtitle: 'Book certified professionals in 1 click',
          actionText: 'See All (8)'
        },
        action: {
          type: 'toast',
          payload: { message: 'Viewing full services catalog...' }
        },
        styles: { margin: [8, 16, 8, 16] }
      },
      {
        id: 'comp_grid_1',
        type: 'service_grid',
        props: {
          columns: 4,
          items: [
            {
              title: 'Repairs',
              icon: 'build',
              badge: 'Top Rated',
              action: { type: 'toast', payload: { message: 'Booking gadget repair...' } }
            },
            {
              title: 'Cleaning',
              icon: 'cleaning_services',
              badge: '20% OFF',
              action: { type: 'toast', payload: { message: 'Deep home cleaning selected!' } }
            },
            {
              title: 'Plumbing',
              icon: 'plumbing',
              badge: null,
              action: { type: 'toast', payload: { message: 'Emergency plumbing scheduled!' } }
            },
            {
              title: 'Electrician',
              icon: 'bolt',
              badge: 'Express',
              action: { type: 'toast', payload: { message: 'Express electrician dispatched!' } }
            }
          ]
        },
        styles: { margin: [0, 16, 12, 16] }
      },
      {
        id: 'comp_promo_1',
        type: 'promo_card',
        props: {
          title: 'SDUI Community Voucher',
          discount: 'FLAT $25 OFF',
          code: 'SDUI25',
          description: 'Valid on all orders above $50. Tap copy code to apply instantly.',
          expires: 'Expires in 48 hours'
        },
        action: {
          type: 'copy_code',
          payload: {
            code: 'SDUI25',
            message: "Coupon code 'SDUI25' copied to clipboard!"
          }
        },
        styles: {
          backgroundColor: '#059669',
          textColor: '#FFFFFF',
          margin: [4, 16, 16, 16]
        }
      },
      {
        id: 'comp_section_trending',
        type: 'section_title',
        props: {
          title: 'Spotlight Product',
          subtitle: 'Top rated product of the week',
          actionText: 'Browse More'
        },
        action: {
          type: 'toast',
          payload: { message: 'Opening trending collections...' }
        },
        styles: { margin: [4, 16, 8, 16] }
      },
      {
        id: 'comp_product_1',
        type: 'product_card',
        props: {
          title: 'Pro Sound Studio ANC Wireless Headphones',
          description: 'Active noise cancellation, transparency mode, 45h battery life.',
          price: '$129.99',
          originalPrice: '$219.00',
          rating: '4.9 ★',
          reviews: '(1,450)',
          tag: 'TOP SELLER',
          imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=700&q=80'
        },
        action: {
          type: 'dialog',
          payload: {
            title: 'Added to Cart 🛍️',
            message: 'Pro Sound Studio ANC Headphones ($129.99) added to your cart!'
          }
        },
        styles: { margin: [0, 16, 16, 16] }
      },
      {
        id: 'comp_section_carousel',
        type: 'section_title',
        props: {
          title: 'Featured Curations',
          subtitle: 'Hand-picked categories to explore'
        },
        styles: { margin: [4, 16, 8, 16] }
      },
      {
        id: 'comp_carousel_1',
        type: 'carousel',
        props: {
          items: [
            {
              title: 'Smart Home',
              subtitle: 'Next-gen connected living',
              imageUrl: 'https://images.unsplash.com/photo-1558002038-1055907df827?w=600&q=80',
              tag: 'NEW',
              action: { type: 'toast', payload: { message: 'Smart Home catalog opened' } }
            },
            {
              title: 'Studio Gear',
              subtitle: 'Pro audio & microphones',
              imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600&q=80',
              tag: 'TRENDING',
              action: { type: 'toast', payload: { message: 'Studio Gear catalog opened' } }
            },
            {
              title: 'Fitness Tech',
              subtitle: 'Track workouts & heart rate',
              imageUrl: 'https://images.unsplash.com/photo-1510519138161-58474ebf8463?w=600&q=80',
              tag: 'HOT',
              action: { type: 'toast', payload: { message: 'Fitness Tech catalog opened' } }
            }
          ]
        },
        styles: { margin: [0, 0, 16, 0] }
      },
      {
        id: 'comp_spacer_1',
        type: 'spacer',
        props: { height: 12 }
      },
      {
        id: 'comp_button_1',
        type: 'button_action',
        props: {
          text: 'Explore All Categories & Stores ➔',
          variant: 'primary'
        },
        action: {
          type: 'toast',
          payload: { message: 'Navigating to global store directory...' }
        },
        styles: {
          backgroundColor: '#6366F1',
          textColor: '#FFFFFF',
          margin: [0, 16, 32, 16]
        }
      }
    ]
  },
  explore: {
    screenId: 'explore',
    title: 'Explore & Discover',
    version: '1.0.0',
    updatedAt: new Date().toISOString(),
    theme: {
      primaryColor: '#EC4899',
      backgroundColor: '#0F172A',
      surfaceColor: '#1E293B',
      textColor: '#F8FAFC',
      accentColor: '#F43F5E'
    },
    components: [
      {
        id: 'comp_explore_search',
        type: 'search_bar',
        props: {
          placeholder: 'Discover trending ideas, creators & brands...',
          showFilter: false
        },
        styles: { margin: [12, 16, 8, 16] }
      },
      {
        id: 'comp_explore_banner',
        type: 'banner',
        props: {
          badge: 'FEATURED SPOTLIGHT',
          title: 'Server-Driven UI 2026',
          subtitle: 'Change your entire mobile layout and widgets in real-time from the web admin portal without re-releasing the APK!',
          imageUrl: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&q=80',
          ctaText: 'Learn Architecture'
        },
        action: {
          type: 'dialog',
          payload: {
            title: 'SDUI Power 🚀',
            message: 'Server-Driven UI decouples mobile presentation from app releases. Publish from Admin -> Mobile renders instantly!'
          }
        },
        styles: {
          backgroundColor: '#BE185D',
          textColor: '#FFFFFF',
          borderRadius: 16,
          margin: [8, 16, 16, 16]
        }
      }
    ]
  }
};

// API Routes

// 1. Status & Network info
app.get('/api/v1/status', (req, res) => {
  const screens = readScreens();
  const localIps = getLocalIps();
  res.json({
    status: 'online',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    port: PORT,
    localIps,
    screensCount: Object.keys(screens).length,
    screens: Object.keys(screens)
  });
});

// 2. Get screen list
app.get('/api/v1/screens', (req, res) => {
  const screens = readScreens();
  const list = Object.keys(screens).map(key => ({
    screenId: key,
    title: screens[key].title || key,
    version: screens[key].version || '1.0.0',
    updatedAt: screens[key].updatedAt,
    componentsCount: (screens[key].components || []).length
  }));
  res.json({ success: true, screens: list });
});

// 3. Get single screen schema
app.get('/api/v1/screen/:screenId', (req, res) => {
  const { screenId } = req.params;
  const screens = readScreens();
  
  if (!screens[screenId]) {
    return res.status(404).json({
      success: false,
      error: `Screen '${screenId}' not found`,
      availableScreens: Object.keys(screens)
    });
  }

  res.json({
    success: true,
    data: screens[screenId]
  });
});

// 4. Update / Publish single screen schema
app.post('/api/v1/screen/:screenId', (req, res) => {
  const { screenId } = req.params;
  const newSchema = req.body;

  if (!newSchema || typeof newSchema !== 'object') {
    return res.status(400).json({
      success: false,
      error: 'Invalid request body. Expected JSON object.'
    });
  }

  // Basic structural validation
  if (!Array.isArray(newSchema.components)) {
    return res.status(400).json({
      success: false,
      error: "Schema must include a 'components' array."
    });
  }

  // Ensure screenId matches
  newSchema.screenId = screenId;
  newSchema.updatedAt = new Date().toISOString();

  // Read, update, and write
  const screens = readScreens();
  screens[screenId] = newSchema;

  if (writeScreens(screens)) {
    console.log(`[SDUI Backend] Published updated schema for screen: ${screenId} at ${newSchema.updatedAt}`);
    return res.json({
      success: true,
      message: `Screen '${screenId}' successfully updated and published.`,
      data: newSchema
    });
  } else {
    return res.status(500).json({
      success: false,
      error: 'Failed to write screen data to disk.'
    });
  }
});

// 5. Reset to default templates
app.post('/api/v1/screens/reset', (req, res) => {
  if (writeScreens(DEFAULT_SCHEMAS)) {
    console.log('[SDUI Backend] Reset all screens to default templates.');
    return res.json({
      success: true,
      message: 'All screen schemas have been reset to factory defaults.',
      screens: Object.keys(DEFAULT_SCHEMAS)
    });
  } else {
    return res.status(500).json({
      success: false,
      error: 'Failed to reset screen templates.'
    });
  }
});

// 6. Direct APK Download Endpoint
app.get('/api/v1/download-apk', (req, res) => {
  let apkPath = null;
  if (fs.existsSync(APK_LOCAL_PATH)) {
    apkPath = APK_LOCAL_PATH;
  } else if (fs.existsSync(APK_BUILD_PATH)) {
    apkPath = APK_BUILD_PATH;
  }

  if (apkPath) {
    res.download(apkPath, 'sdui-mobile-app.apk', (err) => {
      if (err) {
        console.error('Error sending APK download:', err);
      }
    });
  } else {
    res.status(404).json({
      success: false,
      error: 'APK not found. Please build the Flutter APK first using "flutter build apk --debug".',
      instructions: 'Run "flutter build apk --debug" in D:\\sdui_workspace\\flutter_app'
    });
  }
});

// Catch-all route to serve admin portal for any frontend routes
app.use((req, res) => {
  const indexPath = path.join(adminPortalPath, 'index.html');
  if (fs.existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.send('SDUI Backend is running. Admin Portal index.html not found yet.');
  }
});

// Start Server
app.listen(PORT, '0.0.0.0', () => {
  console.log('========================================================');
  console.log(`  🚀 SDUI Backend Server is live on port ${PORT}`);
  console.log(`  🖥️  Admin Portal: http://localhost:${PORT}`);
  console.log(`  🌐 Local Network Access:`);
  getLocalIps().forEach(ip => {
    console.log(`     -> http://${ip}:${PORT}`);
  });
  console.log(`  📱 SDUI Screen Endpoint: http://localhost:${PORT}/api/v1/screen/home`);
  console.log(`  📦 APK Download Endpoint: http://localhost:${PORT}/api/v1/download-apk`);
  console.log('========================================================');
});
