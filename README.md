# 📝 Note-Taking App – Cloud Native Deployment

## Overview
This is a full-stack cloud-native note-taking application built using React and Flask.  
The backend API is deployed on Google Kubernetes Engine (GKE), and the frontend is hosted via Google Cloud Storage + CDN with HTTPS security. Infrastructure automation is managed using Terraform.

This project simulates a real-world production environment with multi-tier architecture, secure communication, and CI/CD integration.

---

## 🌟 Tech Stack
- **Frontend**: React (Vite), HTML/CSS
- **Backend**: Python Flask API
- **Cloud Platform**: Google Cloud Platform (GCP)
- **Containerization**: Docker
- **Orchestration**: Kubernetes (GKE)
- **Infrastructure as Code**: Terraform
- **Database**: Cloud SQL (PostgreSQL)
- **Networking & Security**: HTTPS (SSL/TLS via GCP Load Balancer and Certificate Manager)

---

## 🚀 Features
- User-friendly interface to create, read, update, and delete notes
- Backend API secured behind GKE Ingress with HTTPS
- Frontend served via Cloud Storage + CDN with SSL
- Infrastructure fully provisioned using Terraform scripts
- Deployment pipeline simulating CI/CD best practices
- Structured logging enabled via GCP Cloud Logging

---

## 🛠️ Deployment Instructions

### Prerequisites
- Google Cloud Platform account
- Terraform installed
- Docker installed
- Kubernetes kubectl CLI installed

### Steps
1. Clone this repository.
2. Navigate to the `terraform/` directory and update the backend configuration.
3. Deploy infrastructure:
   ```bash
   terraform init
   terraform apply
