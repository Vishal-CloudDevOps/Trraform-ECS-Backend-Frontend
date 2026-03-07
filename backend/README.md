# Demo CRUD App — Deploy Guide

## Project Structure
```
demo-app/
├── backend/
│   ├── app/main.py          # FastAPI CRUD app
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── src/index.html       # Angular CRUD UI
│   ├── nginx.conf
│   └── Dockerfile
└── taskdefs/
    ├── backend-task-def.json
    └── frontend-task-def.json
```

---

## 1. Placeholders to Replace

In both task definition JSON files, replace:
| Placeholder | Example |
|---|---|
| `<ACCOUNT_ID>` | `123456789012` |
| `<REGION>` | `ap-south-1` |
| `<YOUR_BACKEND_ALB_DNS>` | `demo-backend-alb-xxx.ap-south-1.elb.amazonaws.com` |

---

## 2. Build & Push — Backend

```bash
cd backend/

# Build
docker build -t demo-backend .

# Tag & push to ECR
aws ecr get-login-password --region <REGION> | \
  docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com

docker tag demo-backend:latest \
  <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/demo-backend:latest

docker push <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/demo-backend:latest
```

---

## 3. Build & Push — Frontend

> **If using a real Angular project**, run `ng build --configuration production` first,
> then update the Dockerfile COPY line from `src/` to `dist/<your-app-name>/browser/`.

```bash
cd frontend/

docker build -t demo-frontend .

docker tag demo-frontend:latest \
  <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/demo-frontend:latest

docker push <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/demo-frontend:latest
```

---

## 4. Register Task Definitions

```bash
aws ecs register-task-definition \
  --cli-input-json file://taskdefs/backend-task-def.json \
  --region <REGION>

aws ecs register-task-definition \
  --cli-input-json file://taskdefs/frontend-task-def.json \
  --region <REGION>
```

---

## 5. Secrets Manager Setup

The backend reads DB credentials from AWS Secrets Manager.
Create a secret named `demo/db` with these keys:

```json
{
  "host": "your-rds-endpoint.rds.amazonaws.com",
  "username": "dbuser",
  "password": "yourpassword"
}
```

```bash
aws secretsmanager create-secret \
  --name demo/db \
  --secret-string '{"host":"...","username":"...","password":"..."}' \
  --region <REGION>
```

---

## 6. IAM — ecsTaskExecutionRole Permissions Needed
- `ecr:GetAuthorizationToken`, `ecr:BatchGetImage`, `ecr:GetDownloadUrlForLayer`
- `logs:CreateLogStream`, `logs:PutLogEvents`
- `secretsmanager:GetSecretValue`

---

## 7. CloudWatch Log Groups

Create these before deploying:

```bash
aws logs create-log-group --log-group-name /ecs/demo-backend --region <REGION>
aws logs create-log-group --log-group-name /ecs/demo-frontend --region <REGION>
```
