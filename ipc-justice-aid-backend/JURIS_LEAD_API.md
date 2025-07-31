# IPC Justice Aid - Juris-Lead Platform API Documentation

## Overview

The Juris-Lead platform provides a comprehensive API for connecting citizens needing legal help with qualified lawyers. The platform offers:

- **Free AI-powered legal analysis** for citizens
- **Lead management system** for lawyers
- **Subscription-based access** to pre-screened cases
- **Real-time notifications** and matching

## Base URL

```
http://localhost:8001/api/v1/
```

## Authentication

Most endpoints require authentication using JWT tokens. Public endpoints include case analysis for citizens.

### Obtain Token
```http
POST /api/v1/auth/login/
Content-Type: application/json

{
    "username": "your_username",
    "password": "your_password"
}
```

### Use Token
```http
Authorization: Bearer <your_jwt_token>
```

## API Endpoints

### 1. Citizen Platform (Free Public Access)

#### Analyze Legal Case
```http
POST /api/v1/leads/analyze-case/
Content-Type: application/json

{
    "case_description": "A man was hit by a car while being drunk. The driver fled the scene.",
    "incident_date": "2025-07-30",
    "incident_location": "Main Street, Downtown",
    "city": "Mumbai",
    "state": "Maharashtra",
    "contact_method": "email",
    "contact_value": "temp_email@example.com",
    "urgency_level": "medium",
    "create_lead": true,
    "generate_pdf": true
}
```

**Response:**
```json
{
    "lead_id": "123e4567-e89b-12d3-a456-426614174000",
    "ai_analysis": {
        "ipc_sections": [
            {
                "section_number": "304B",
                "description": "This section addresses the offense of causing death by dangerous act or omission...",
                "why_applied": "If the intoxicated individual's actions directly led to the accident..."
            }
        ],
        "summary": "The primary IPC section applicable here is Section 304B...",
        "case_category": "criminal",
        "confidence_score": 0.85
    },
    "ipc_sections": ["304B", "269A"],
    "case_category": "criminal",
    "recommended_actions": [
        "Consult with a qualified lawyer for detailed legal advice",
        "Gather all relevant documents and evidence"
    ],
    "pdf_report_url": "/media/reports/case_analysis_123e4567.pdf",
    "lawyer_connect_available": true,
    "estimated_consultation_fee_range": "₹1,000 - ₹5,000"
}
```

### 2. Lawyer Management

#### Create/Update Lawyer Profile
```http
POST /api/v1/leads/lawyer-profiles/
Authorization: Bearer <token>
Content-Type: application/json

{
    "bar_council_id": "MH12345/2020",
    "practice_areas": ["criminal", "civil", "family"],
    "experience_level": "mid",
    "years_of_experience": 5,
    "city": "Mumbai",
    "state": "Maharashtra",
    "court_locations": ["Mumbai Sessions Court", "Bombay High Court"],
    "firm_name": "Legal Associates",
    "languages_spoken": ["English", "Hindi", "Marathi"],
    "consultation_fee": 2500.00,
    "email_notifications": true,
    "sms_notifications": false
}
```

#### Get Lawyer Dashboard Stats
```http
GET /api/v1/leads/dashboard/
Authorization: Bearer <token>
```

**Response:**
```json
{
    "total_leads_viewed": 45,
    "leads_contacted": 12,
    "leads_accepted": 8,
    "leads_rejected": 5,
    "current_month_consumption": 15,
    "monthly_limit": 25,
    "subscription_status": "active",
    "new_leads_today": 3,
    "pending_responses": 2
}
```

### 3. Lead Management

#### Get Available Leads
```http
GET /api/v1/leads/leads/?search=theft&urgency=high&city=Mumbai
Authorization: Bearer <token>
```

**Query Parameters:**
- `search`: Search in case description or category
- `ipc_sections`: Comma-separated IPC sections (e.g., "302,304")
- `urgency`: low, medium, high, critical
- `city`: Filter by city name

**Response:**
```json
{
    "count": 25,
    "next": "http://localhost:8001/api/v1/leads/leads/?page=2",
    "previous": null,
    "results": [
        {
            "lead_id": "123e4567-e89b-12d3-a456-426614174000",
            "case_description": "Brief description...",
            "incident_date": "2025-07-30",
            "city": "Mumbai",
            "state": "Maharashtra",
            "case_category": "theft",
            "urgency_level": "high",
            "ipc_sections_display": ["Section 378", "Section 379"],
            "status": "published",
            "created_at": "2025-07-31T10:30:00Z",
            "time_since_created": "2 hours ago",
            "matching_lawyer_count": 8
        }
    ]
}
```

#### Express Interest in Lead
```http
POST /api/v1/leads/leads/{lead_id}/express_interest/
Authorization: Bearer <token>
Content-Type: application/json

{
    "message": "I am interested in this case and have 5 years experience in similar matters."
}
```

#### Contact Client
```http
POST /api/v1/leads/leads/{lead_id}/contact_client/
Authorization: Bearer <token>
Content-Type: application/json

{
    "message": "Hello, I am advocate John Doe with 10 years experience in criminal law. I can help you with your case. My consultation fee is ₹2,500. Please contact me at john@legal.com"
}
```

### 4. Subscription Management

#### Get Subscription Details
```http
GET /api/v1/leads/subscriptions/
Authorization: Bearer <token>
```

#### Upgrade Subscription
```http
POST /api/v1/leads/subscriptions/upgrade_subscription/
Authorization: Bearer <token>
Content-Type: application/json

{
    "tier": "solo_practitioner"
}
```

**Available Tiers:**
- `pro_bono`: Free (5 leads/month)
- `solo_practitioner`: ₹2,000/month (25 leads/month)
- `small_firm`: ₹8,000/month (100 leads/month)
- `enterprise`: ₹25,000/month (1000 leads/month)

### 5. System Health & Analytics

#### System Health Check
```http
GET /api/v1/leads/health/
```

**Response:**
```json
{
    "status": "healthy",
    "timestamp": "2025-07-31T15:30:00Z",
    "services": {
        "database": "healthy",
        "ollama": "healthy"
    }
}
```

#### Analytics (Admin Only)
```http
GET /api/v1/leads/analytics/?days=30
Authorization: Bearer <admin_token>
```

## Error Handling

All API endpoints return consistent error responses:

```json
{
    "error": "Error type",
    "message": "Human-readable error message",
    "details": "Additional technical details (in debug mode)"
}
```

### Common HTTP Status Codes

- `200 OK`: Request successful
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid request data
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Permission denied
- `404 Not Found`: Resource not found
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Server error

## Rate Limiting

- Anonymous users: 100 requests per hour
- Authenticated users: 1000 requests per hour
- Case analysis: 5 requests per hour per IP for anonymous users

## WebSocket Integration (Future)

Real-time notifications for lawyers:

```javascript
const ws = new WebSocket('ws://localhost:8001/ws/leads/');
ws.onmessage = function(event) {
    const data = JSON.parse(event.data);
    if (data.type === 'new_lead') {
        // Handle new lead notification
    }
};
```

## Sample Integration

### Frontend JavaScript Example

```javascript
// Analyze case for citizen
async function analyzeCase(caseData) {
    const response = await fetch('/api/v1/leads/analyze-case/', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(caseData)
    });
    
    if (response.ok) {
        const result = await response.json();
        console.log('Analysis result:', result);
        return result;
    } else {
        throw new Error('Analysis failed');
    }
}

// Get leads for lawyer
async function getLeads(token, filters = {}) {
    const params = new URLSearchParams(filters);
    const response = await fetch(`/api/v1/leads/leads/?${params}`, {
        headers: {
            'Authorization': `Bearer ${token}`
        }
    });
    
    if (response.ok) {
        return await response.json();
    } else {
        throw new Error('Failed to fetch leads');
    }
}
```

### Python Example

```python
import requests

# Analyze case
def analyze_case(case_description, location_info):
    data = {
        "case_description": case_description,
        "city": location_info["city"],
        "state": location_info["state"],
        "contact_method": "email",
        "contact_value": "temp@example.com",
        "create_lead": True
    }
    
    response = requests.post(
        "http://localhost:8001/api/v1/leads/analyze-case/",
        json=data
    )
    
    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f"Analysis failed: {response.text}")

# Get lawyer dashboard
def get_dashboard_stats(token):
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(
        "http://localhost:8001/api/v1/leads/dashboard/",
        headers=headers
    )
    
    return response.json()
```

## Testing the API

### 1. Start the Platform
```bash
cd ipc-justice-aid-backend
./startup-juris-lead.sh
```

### 2. Test Case Analysis
```bash
curl -X POST http://localhost:8001/api/v1/leads/analyze-case/ \
  -H "Content-Type: application/json" \
  -d '{
    "case_description": "A man was hit by a car while being drunk",
    "city": "Mumbai",
    "state": "Maharashtra",
    "contact_method": "email",
    "contact_value": "test@example.com",
    "create_lead": true
  }'
```

### 3. Test Ollama Integration
```bash
curl -X GET http://localhost:8001/api/v1/leads/health/
```

This should show the Ollama service status and confirm your IPC-Helper model is working.

## Production Deployment

For production deployment with Docker:

```bash
# Use the production Docker Compose file
docker-compose -f docker-compose-juris-lead.yml up -d

# Check logs
docker-compose -f docker-compose-juris-lead.yml logs -f web
```

The platform is now ready to handle both citizen case analysis and lawyer lead management according to your Juris-Lead business model!
