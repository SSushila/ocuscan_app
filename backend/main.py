from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import torch
import torchvision.transforms as transforms
from PIL import Image
import io
import pandas as pd
import numpy as np
from vit_retina import MobileRetinaViT

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Disease name mapping
DISEASE_NAMES = {
    'NORMAL': 'Normal Retina',
    'DR': 'Diabetic Retinopathy',
    'ARMD': 'Age-related Macular Degeneration',
    'BRVO': 'Branch Retinal Vein Occlusion',
    'CRVO': 'Central Retinal Vein Occlusion',
    'CSR': 'Central Serous Retinopathy',
    'CRS': 'Chorioretinitis',
    'CNV': 'Choroidal Neovascularization',
    'DN': 'Drusen',
    'HTR': 'Hypertensive Retinopathy',
    'LS': 'Lattice Degeneration',
    'MH': 'Macular Hole',
    'MYA': 'Myopia',
    'ODE': 'Optic Disc Edema',
    'ODC': 'Optic Disc Cupping',
    'ODP': 'Optic Disc Pallor',
    'RS': 'Retinal Scar',
    'TSLN': 'Tessellated Fundus',
    'ASR': 'Acute Serous Retinopathy',
    'OTHER': 'Other Conditions'
}

# Set device
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f'Using device: {device}')

# Load disease columns from training data
train_data = pd.read_csv('Model/train_data.csv')
disease_columns = [col for col in train_data.columns if col != 'ID']

# Initialize and load model
model = MobileRetinaViT(num_classes=len(disease_columns)).to(device)
checkpoint = torch.load('Model/best_vit_model.pth', map_location=device)
model.load_state_dict(checkpoint['model_state_dict'])
model.eval()
print("Model loaded successfully")

# Define image transformations
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

def predict_image(image):
    """
    Predict diseases for a single image.
    
    Args:
        image: PIL Image object
    
    Returns:
        Dictionary of disease predictions with probabilities
    """
    try:
        print("Starting image prediction...")
        # Convert image to RGB
        image = image.convert('RGB')
        print("Image converted to RGB")
        
        # Apply transformations
        image_tensor = transform(image).unsqueeze(0).to(device)
        print(f"Image tensor shape: {image_tensor.shape}")
        
        # Make prediction
        model.eval()
        with torch.no_grad():
            outputs = model(image_tensor)
            probabilities = outputs.cpu().numpy()[0]
            print(f"Raw probabilities shape: {probabilities.shape}")
        
        # Create dictionary of predictions
        predictions = {}
        for disease, prob in zip(disease_columns, probabilities):
            predictions[disease] = {
                'probability': float(prob),
                'detected': bool(prob > 0.5),
                'full_name': DISEASE_NAMES.get(disease, disease)  # Add full name
            }
        
        print("\nPredicted Diseases:")
        print("-" * 50)
        # First show detected diseases
        detected_diseases = [(disease, pred['probability']) 
                           for disease, pred in predictions.items() 
                           if pred['detected']]
        
        if detected_diseases:
            print("\nDetected Diseases:")
            for disease, prob in sorted(detected_diseases, key=lambda x: x[1], reverse=True):
                print(f"• {DISEASE_NAMES.get(disease, disease)} (Confidence: {prob:.2%})")
        else:
            print("No diseases were detected in the image.")
        
        print("\nDetailed Analysis:")
        print("-" * 50)
        for disease, pred in sorted(predictions.items(), key=lambda x: x[1]['probability'], reverse=True):
            print(f"{DISEASE_NAMES.get(disease, disease)}:")
            print(f"  Confidence: {pred['probability']:.2%}")
            print("-" * 50)
        
        return predictions
    
    except Exception as e:
        print(f"Error in predict_image: {str(e)}")
        print(f"Error type: {type(e)}")
        import traceback
        print(f"Traceback: {traceback.format_exc()}")
        return None

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        print(f"Received file: {file.filename}")
        # Read the image
        contents = await file.read()
        print(f"File size: {len(contents)} bytes")
        
        image = Image.open(io.BytesIO(contents))
        print(f"Image size: {image.size}, mode: {image.mode}")
        
        # Get predictions
        predictions = predict_image(image)
        
        if predictions is None:
            raise HTTPException(
                status_code=500,
                detail="Failed to process the image. Please try again."
            )
        
        # Return predictions directly in the format the frontend expects
        return predictions

    except Exception as e:
        print(f"Error in /predict endpoint: {str(e)}")
        print(f"Error type: {type(e)}")
        import traceback
        print(f"Traceback: {traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    import os
    
    # Change to the backend directory
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    uvicorn.run(app, host="0.0.0.0", port=8000) 