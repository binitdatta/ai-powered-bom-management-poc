```
# AI-Powered BOM Management POC

Enterprise proof-of-concept stress-testing AI and modern cloud-native technology claims in a real Fortune 500 BOM management context.

## Architecture

```
Browser ──PKCE──▶ Keycloak 26 (port 8080, realm: bomiq)
Browser ◀──────── Flask ChatBot (port 5001)
Flask   ──JWT───▶ Spring Boot REST API (port 9086/bomiq/api/v1)
Flask   ──────── Claude Sonnet (Anthropic API)
Flask   ──────── openpyxl → .xlsx downloads
MySQL 8 ◀──────── Spring Boot JPA
```

## Technology Stack

| Layer | Technology |
|---|---|
| BOM REST API | Spring Boot 3.5, Spring Security, Spring Data JPA |
| UI | Thymeleaf, Bootstrap 5, Bootstrap Icons |
| AI ChatBot | Python 3.12, Flask, Gunicorn |
| AI Engine | Anthropic Claude Sonnet, LangGraph |
| Auth | Keycloak 26, PKCE S256, JWT |
| Database | MySQL 8, DBA-owned DDL |
| Reports | openpyxl Excel workbooks |

## Repository Structure

```
ai-powered-bom-management-poc/
├── spring-boot/                  # Spring Boot REST API + Thymeleaf UI
│   ├── src/main/java/            # Java source — com.bomiq.sdm
│   ├── src/main/resources/       # application.yml, templates, SQL
│   └── keycloak-realm/           # bomiq-realm.json for Keycloak import
├── flask-chatbot/                # Python Flask AI ChatBot
│   ├── app/                      # Flask application package
│   │   ├── auth/                 # Keycloak PKCE flow
│   │   ├── bom/                  # Spring Boot REST API client
│   │   ├── chat/                 # LangGraph intent detection + SSE handlers
│   │   └── excel/                # openpyxl report builder
│   ├── config/                   # Settings from .env
│   ├── wsgi.py                   # Gunicorn entry point
│   ├── gunicorn.conf.py          # gthread worker config
│   ├── requirements.txt
│   ├── .env.example              # Copy to .env and fill in secrets
│   └── README.md                 # Full setup instructions
└── README.md                     # This file
```

## Features

- Natural language BOM validation with AI analysis (GREEN/YELLOW/RED health)
- Multi-level BOM hierarchy — 20 seeded BOMs across 3 levels
- Component lifecycle and RoHS compliance checking
- Supplier risk assessment
- Downloadable Excel reports — 6-tab validation workbook
- SSE streaming responses — real-time AI output
- Role-based access — bomiq-admin, bomiq-engineer, bomiq-viewer
- Stateless PKCE auth — no cookie dependency, works in all browsers

## Quick Start

### Prerequisites

- Java 21
- Python 3.12
- MySQL 8
- Keycloak 26

### 1. Keycloak

Import `spring-boot/keycloak-realm/bomiq-realm.json` into Keycloak to create the bomiq realm with all users, roles and client pre-configured.

### 2. MySQL

Create schema `bomiq_sdm` and run the DDL and seed scripts from `spring-boot/src/main/resources/`.

### 3. Spring Boot

```bash
cd spring-boot
mvn clean install -DskipTests
java -jar target/bomiq-sdm-1.0.0-SNAPSHOT.jar
```

App runs at: http://localhost:9086/bomiq

### 4. Flask ChatBot

```bash
cd flask-chatbot
python3.12 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env — add ANTHROPIC_API_KEY
gunicorn -c gunicorn.conf.py wsgi:app
```

App runs at: http://localhost:5001

Full instructions: `flask-chatbot/README.md`

## Chat Prompts

```
Validate BOM BOM-EC5000-001
List all active BOMs
Show the BOM hierarchy tree
Show all obsolete and NRND parts
List all Tier 1 suppliers
What is the cost of BOM BOM-EC5000-001?
Show platform statistics
Help
```

## Security Notes

- `.env` is gitignored — never committed
- PKCE verifier embedded in signed state parameter — no cookie dependency
- JWT Bearer token required for all REST API calls
- Role-based authorization on write operations

## Author

Binit Datta — Enterprise AI POC Series
```
