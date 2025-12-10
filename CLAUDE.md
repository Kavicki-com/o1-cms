# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

O1 CMS is a web-based application management system for reviewing, approving, or rejecting user applications. It's a vanilla JavaScript single-page application with Supabase backend integration.

## Development Commands

### Starting the Application
```bash
./INICIAR.sh
```
This script:
- Kills any existing server on port 8000
- Starts a Python HTTP server on port 8000
- Opens the browser to the login page

### Stopping the Server
```bash
pkill -f 'python3 -m http.server'
```

### Access Points
- **Login**: http://localhost:8000/login.html
- **Dashboard**: http://localhost:8000/index.html
- **Password Recovery**: http://localhost:8000/forgot-password.html
- **Password Update**: http://localhost:8000/update-password.html

## Architecture

### Technology Stack
- **Frontend**: Vanilla JavaScript (ES6 modules), HTML5, CSS3
- **Backend**: Supabase (authentication, database, storage)
- **Server**: Python HTTP server (development only)
- **Fonts**: Google Fonts (Inter)

### File Structure
- `index.html` - Main dashboard for managing applications
- `login.html` - Authentication page with email allowlist
- `forgot-password.html` - Password recovery flow
- `update-password.html` - Password reset confirmation
- `style.css` - Shared styles for auth pages
- `style-index.css` - Dashboard-specific styles
- `assets/` - Static assets (favicon, logo)
- `INICIAR.sh` - Development server startup script

### Authentication & Authorization

The application uses a **two-tier authorization model**:

1. **Email Allowlist** (client-side check in login.html:57-64):
   - Only specific emails can access the CMS
   - Hardcoded list of authorized users:
     - masesdev@gmail.com
     - jorge@kavicki.com
     - info@o1percent.com
     - matheusmondenez@gmail.com
     - maximiliaan.van.kuyk@gmail.com
     - silveryehuda@gmail.com

2. **Supabase Authentication** (backend):
   - After passing allowlist check, credentials are verified via Supabase
   - Session management handled by Supabase SDK
   - Auth state changes monitored via `onAuthStateChange()`

**Important**: To add new authorized users, update the `allowedUsers` array in `login.html` AND ensure they have valid Supabase accounts.

### Supabase Configuration

**Connection Details** (hardcoded in HTML files):
- URL: `https://acziwjxffpcovfzxduuo.supabase.co`
- Anon Key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (see source files)

**Database Schema**:
- Table: `profiles`
- Fields accessed:
  - `id` - Unique identifier
  - `name` - Applicant name
  - `email` - Applicant email
  - `city` - Location
  - `phone` - Contact number
  - `status` - Application state: 'pending' | 'approved' | 'rejected'
  - `short_bio` - Brief description
  - `why_accepted` - Motivation text
  - `industries` - Array of industry tags
  - `invited_by` - Referral source
  - `instagram` - Social handle
  - `impact_links` - Array of URLs
  - `profile_photo` - Path to profile image
  - `photos` - Array of additional photo paths
  - `created_at` - Submission timestamp

**Storage**:
- Bucket: `profile-photos`
- Used for profile pictures and additional user photos
- Public URL generation via `supabaseClient.storage.from(bucket).getPublicUrl(path)`

### Application Flow

1. **Login** (`login.html`):
   - User enters credentials
   - Email validated against allowlist
   - Supabase authentication performed
   - Redirect to `index.html` on success

2. **Dashboard** (`index.html`):
   - Auth guard checks session (redirects to login if none)
   - Fetch all applications from `profiles` table
   - Display in filterable grid (pending/approved/rejected)
   - Search by name
   - View detailed modal for each application
   - Approve/reject actions update status in database

3. **Password Recovery Flow**:
   - `forgot-password.html` sends reset email via Supabase
   - User clicks link in email
   - `update-password.html` handles password update
   - Uses Supabase `PASSWORD_RECOVERY` event

### Key Features

**Application Cards** (index.html:124-188):
- Show profile photo, name, email, city
- Display status badge with icon
- List selected industries
- Preview short bio
- Submission timestamp
- Action buttons: View Details, Approve, Deny

**Application Modal** (index.html:191-313):
- Full application details
- Clickable photos (opens lightbox)
- Social links (Instagram)
- Copy-to-clipboard for impact links
- Approve/reject actions (for pending only)

**Image Lightbox** (index.html:323-337):
- Full-screen photo viewer
- Triggered by clicking profile photo or gallery images

**Status Management**:
- Real-time updates via Supabase
- Local state sync after status changes
- Automatic re-filtering after updates

### Code Patterns

**Supabase Client Initialization**:
```javascript
const { createClient } = supabase;
const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
```

**Auth State Monitoring**:
```javascript
supabaseClient.auth.onAuthStateChange((_event, session) => {
    if (!session) {
        window.location.href = 'login.html';
    }
});
```

**Fetching Data**:
```javascript
const { data, error } = await supabaseClient
    .from(TABLE_NAME)
    .select('*')
    .order('created_at', { ascending: false });
```

**Updating Records**:
```javascript
const { error } = await supabaseClient
    .from(TABLE_NAME)
    .update({ status })
    .eq('id', id);
```

**Public URL Generation**:
```javascript
const url = supabaseClient.storage
    .from(PHOTO_BUCKET_NAME)
    .getPublicUrl(photoPath).data.publicUrl;
```

### Styling Approach

- Custom CSS (no frameworks)
- CSS Grid for layouts
- Flexbox for components
- CSS transitions for modals/lightbox
- Dark theme color scheme
- Responsive design patterns

### Important Notes

- All JavaScript is inline in HTML files (no separate .js files)
- ES6 modules used for Supabase import
- No build process or transpilation
- No package.json or npm dependencies
- Supabase SDK loaded via CDN (`unpkg.com`)
- Configuration values are hardcoded (not in environment variables)
