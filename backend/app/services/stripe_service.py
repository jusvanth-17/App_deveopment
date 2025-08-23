import stripe as stripe_sdk
from typing import Optional
from app.core.config import settings


class StripeService:
	def __init__(self) -> None:
		if not settings.stripe_api_key:
			raise RuntimeError("STRIPE_API_KEY not configured")
		stripe_sdk.api_key = settings.stripe_api_key

	def get_customer(self, customer_id: str) -> Optional[dict]:
		try:
			return stripe_sdk.Customer.retrieve(customer_id)
		except Exception:
			return None