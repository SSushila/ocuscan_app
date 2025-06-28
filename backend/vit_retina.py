import torch
import torch.nn as nn
import timm

class MobileRetinaViT(nn.Module):
    def __init__(self, num_classes, pretrained=True):
        super(MobileRetinaViT, self).__init__()
        # Use a smaller ViT model suitable for mobile
        self.vit = timm.create_model('vit_small_patch16_224', pretrained=pretrained)
        self.vit.head = nn.Linear(self.vit.head.in_features, num_classes)
        
        # Add dropout for regularization
        self.dropout = nn.Dropout(0.2)

    def forward(self, x):
        x = self.vit(x)
        x = self.dropout(x)
        return torch.sigmoid(x)  # Use sigmoid for multi-label classification 