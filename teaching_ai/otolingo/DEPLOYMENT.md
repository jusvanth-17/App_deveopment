# Firebase Cloud Functions Deployment Guide

This guide will walk you through deploying your language learning application to Firebase Cloud Functions.

## Prerequisites

1. Firebase CLI installed
   ```bash
   npm install -g firebase-tools
   ```

2. Firebase project initialized
   ```bash
   firebase login
   firebase init
   ```

3. Environment variables set up (OPENAI_API_KEY)

## Local Testing

Before deploying to Firebase, you should test your function locally:

1. Make sure your `.env` file is in the `teaching_ai/otolingo` directory with your OpenAI API key:
   ```
   OPENAI_API_KEY=your_openai_api_key_here
   ```

2. Install dependencies:
   ```bash
   cd teaching_ai/otolingo
   pip install -r requirements.txt
   ```

3. Run the function locally:
   ```bash
   python main.py
   ```

4. In a separate terminal, run the test script:
   ```bash
   python test_function.py
   ```

## Deployment to Firebase

Once you've confirmed that the function works locally:

1. Ensure your Firebase project is set up and the `.firebaserc` file has the correct project ID.

2. Set up environment variables in Firebase:
   ```bash
   firebase functions:secrets:set OPENAI_API_KEY
   ```
   When prompted, enter your OpenAI API key.

3. Update your function to use the Firebase secret instead of dotenv when in production:
   ```python
   # In main.py, update the OPENAI_API_KEY initialization:
   
   # Try to get from Firebase secrets first, then fall back to dotenv for local development
   try:
       from firebase_functions import params
       OPENAI_API_KEY = params.SECRET.OPENAI_API_KEY
   except (ImportError, AttributeError):
       # Fall back to dotenv for local development
       load_dotenv()
       OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
   ```

4. Deploy your function:
   ```bash
   firebase deploy --only functions
   ```

5. After deployment, Firebase will output the URL for your function. This is the endpoint you should use in your Flutter app's API service.

## Updating the Flutter App

Update your Flutter app's API service to use the new Firebase Cloud Function URL:

1. Open `teaching_ai/lib/services/api_service.dart`
2. Update the base URL to your Firebase Function URL
3. Ensure your API calls match the endpoints defined in your Cloud Function

## Troubleshooting

- **Logs**: View function logs in the Firebase Console or using the CLI:
  ```bash
  firebase functions:log
  ```

- **Cold Start**: Be aware that Cloud Functions have a cold start time. The first request after deployment or inactivity may take longer to respond.

- **Memory/Timeout**: If your function is timing out or running out of memory, you may need to adjust the configuration in your code:
  ```python
  @https_fn.on_request(memory=1024, timeout_sec=60)
  def api(req: Request) -> Response:
      # Your function code
  ```

- **CORS**: If you're experiencing CORS issues, ensure your CORS middleware in FastAPI is correctly configured.
