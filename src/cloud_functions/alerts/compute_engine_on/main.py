import os
import smtplib
from datetime import datetime, timezone
from email.message import EmailMessage

# Añadir soporte para cargar variables desde .env si está presente
from dotenv import load_dotenv
load_dotenv()

import google.auth
from googleapiclient.discovery import build


def check_instances_and_notify(request, context=None):
    """
    Cloud Function to check Compute Engine instances and send alerts.
    
    Args:
        request: HTTP request object (for HTTP triggers) or Pub/Sub message (for Pub/Sub triggers)
        context: Cloud Function context (optional, for Pub/Sub triggers)
    """
    print(f"Function triggered with request type: {type(request)}")
    if context:
        print(f"Context: {context}")
    
    # Get configuration from environment variables
    threshold_minutes = int(os.getenv('ALERT_THRESHOLD_MINUTES', '30'))
    zones = os.getenv('COMPUTE_ZONES', 'europe-west1-b,europe-west1-c').split(',')
    
    print(f"Checking zones: {zones}")
    print(f"Threshold minutes: {threshold_minutes}")
    
    credentials, project = google.auth.default()
    compute = build("compute", "v1", credentials=credentials)
    print(f"Credenciales: {credentials}")
    print(f"Service account email: {getattr(credentials, 'service_account_email', None)}")
    print(f"Project: {project}")

    alerted_instances = []
    now = datetime.now(timezone.utc)
    print(f"Current time: {now}")

    for zone in zones:
       
        zone = zone.strip()
        print(f"Checking zone: {zone}")
        result = compute.instances().list(project=project, zone=zone).execute()
        
        print(f"Found {len(result.get('items', []))} instances in zone {zone}")
        if "items" not in result:
            print(f"No instances found in zone {zone}")
            continue

        for instance in result["items"]:
            instance_name = instance["name"]
            instance_status = instance["status"]
            print(f"Checking instance: {instance_name} (status: {instance_status})")
            
            if instance["status"] == "RUNNING":
                # Use startTime if available, otherwise fallback to creationTimestamp
                print( instance.keys())
                timestamp_str = instance.get("lastStartTimestamp")
                
                try:
                    # Handle different timestamp formats
                    if timestamp_str.endswith("Z"):
                        # Format: "2024-01-15T10:30:00.000Z"
                        launch_time = datetime.fromisoformat(timestamp_str.replace("Z", "+00:00"))
                    elif "+" in timestamp_str or "-" in timestamp_str[-6:]:
                        # Format: "2024-01-15T10:30:00.000+00:00" or "2024-01-15T10:30:00.000-07:00"
                        launch_time = datetime.fromisoformat(timestamp_str)
                    else:
                        # Format: "2024-01-15T10:30:00.000" (no timezone)
                        launch_time = datetime.fromisoformat(timestamp_str + "+00:00")
                    
                    uptime_minutes = (now - launch_time).total_seconds() / 60
                    print(f"Instance {instance_name} uptime: {uptime_minutes:.2f} minutes (since {timestamp_str})")
                    
                    if uptime_minutes > threshold_minutes:
                        print(f"ALERT: Instance {instance_name} exceeds threshold!")
                        alerted_instances.append((instance_name, zone, int(uptime_minutes)))
                    else:
                        print(f"Instance {instance_name} is within threshold")
                        
                except Exception as e:
                    print(f"Error parsing timestamp for {instance_name}: {e}")
                    print(f"Timestamp string: {timestamp_str}")
                    continue
            else:
                print(f"Instance {instance_name} is not running (status: {instance_status})")
      
    
    print(f"Total instances checked. Found {len(alerted_instances)} instances exceeding threshold")
    
    if alerted_instances:
        body = "\n".join(
            [
                f"🔴 Instancia '{name}' en zona '{zone}' lleva {mins} minutos encendida"
                for name, zone, mins in alerted_instances
            ]
        )
        print(f"Sending email alert with body: {body}")
        send_email("Instancias encendidas demasiado tiempo", body)
        print(f"Alert sent for {len(alerted_instances)} instances")
    else:
        print("No instances found running longer than threshold")

    print("Function execution completed successfully")
    return "Done"


def send_email(subject, body):
    email = os.getenv('EMAIL')
    smtp_password = os.getenv('SMTP_PASSWORD')
    smtp_user =email
    smtp_server = os.getenv('SMTP_SERVER', 'smtp.gmail.com')
    smtp_port = int(os.getenv('SMTP_PORT', '587'))

    if not email or not smtp_password:
        print("EMAIL or SMTP_PASSWORD environment variable not set")
        return

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = email
    msg["To"] = email
    msg.set_content(body)

    try:
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(smtp_user, smtp_password)
            server.send_message(msg)
        print(f"Email sent successfully to {email}")
    except Exception as e:
        print(f"Error sending email: {e}")
