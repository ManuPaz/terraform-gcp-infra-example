"""
Compute Engine monitoring Cloud Function.
Monitors Compute Engine instances and sends alerts for long-running instances.
"""

from .main import check_instances_and_notify, send_email

__all__ = ['check_instances_and_notify', 'send_email'] 