#!/usr/bin/env python3
"""
Research script to find the best models for legal analysis
"""
import requests
import json

def search_huggingface_models():
    """Search for legal and instruction-following models on Hugging Face"""
    
    print("🔍 Researching Best Models for Legal Analysis")
    print("=" * 60)
    
    # Categories of models that would work well for legal analysis
    model_categories = {
        "Legal-Specific Models": [
            "nlpaueb/legal-bert-base-uncased",
            "zlucia/custom-legalbert", 
            "law-ai/InLegalBERT",
            "lexlms/legal-bert-base",
            "saradhix/legal_bert_uncased",
            "pile-of-law/legalbert-large-1.7M-2",
        ],
        
        "Large Instruction Models (Good for Legal Reasoning)": [
            # Llama 2 models
            "meta-llama/Llama-2-7b-chat-hf",
            "meta-llama/Llama-2-13b-chat-hf", 
            "meta-llama/Llama-2-70b-chat-hf",
            
            # Mistral models  
            "mistralai/Mistral-7B-Instruct-v0.1",
            "mistralai/Mistral-7B-Instruct-v0.2",
            "mistralai/Mixtral-8x7B-Instruct-v0.1",
            
            # Code Llama (good for structured output)
            "codellama/CodeLlama-7b-Instruct-hf",
            "codellama/CodeLlama-13b-Instruct-hf",
            
            # Vicuna models
            "lmsys/vicuna-7b-v1.5",
            "lmsys/vicuna-13b-v1.5",
            
            # Zephyr models
            "HuggingFaceH4/zephyr-7b-beta",
            "HuggingFaceH4/zephyr-7b-alpha",
        ],
        
        "Large General Models": [
            # Google models
            "google/flan-t5-large",
            "google/flan-t5-xl", 
            "google/flan-t5-xxl",
            "google/flan-ul2",
            
            # Falcon models
            "tiiuae/falcon-7b-instruct",
            "tiiuae/falcon-40b-instruct",
            
            # MPT models
            "mosaicml/mpt-7b-instruct",
            "mosaicml/mpt-30b-instruct",
        ],
        
        "Qwen Models (Latest)": [
            "Qwen/Qwen-7B-Chat",
            "Qwen/Qwen-14B-Chat", 
            "Qwen/Qwen-72B-Chat",
            "Qwen/Qwen1.5-7B-Chat",
            "Qwen/Qwen1.5-14B-Chat",
            "Qwen/Qwen1.5-72B-Chat",
            "Qwen/Qwen2-7B-Instruct",
            "Qwen/Qwen2-72B-Instruct",
            "Qwen/Qwen3-30B-A3B-Instruct-2507",  # The one you wanted to try
        ]
    }
    
    print("📊 RECOMMENDED MODELS FOR LEGAL ANALYSIS")
    print("=" * 60)
    
    for category, models in model_categories.items():
        print(f"\n🏷️  {category}")
        print("-" * 40)
        for model in models:
            print(f"   • {model}")
    
    print("\n" + "=" * 60)
    print("🎯 TOP RECOMMENDATIONS FOR YOUR USE CASE")
    print("=" * 60)
    
    recommendations = [
        {
            "model": "mistralai/Mistral-7B-Instruct-v0.2",
            "pros": "Best balance of performance and size, excellent instruction following, good for legal reasoning",
            "cons": "Requires Pro access on HF",
            "size": "7B parameters"
        },
        {
            "model": "meta-llama/Llama-2-7b-chat-hf", 
            "pros": "Excellent for structured output, trained on diverse data including legal texts",
            "cons": "Requires Pro access, may need approval",
            "size": "7B parameters"
        },
        {
            "model": "google/flan-t5-xl",
            "pros": "Good instruction following, might be available on free tier",
            "cons": "Smaller than modern models",
            "size": "3B parameters"
        },
        {
            "model": "Qwen/Qwen2-7B-Instruct",
            "pros": "Latest generation, excellent performance, good multilingual support",
            "cons": "Requires Pro access",
            "size": "7B parameters"
        },
        {
            "model": "HuggingFaceH4/zephyr-7b-beta",
            "pros": "Open source, good instruction following, optimized for helpfulness",
            "cons": "May require Pro access",
            "size": "7B parameters"
        }
    ]
    
    for i, rec in enumerate(recommendations, 1):
        print(f"\n{i}. {rec['model']}")
        print(f"   📏 Size: {rec['size']}")
        print(f"   ✅ Pros: {rec['pros']}")
        print(f"   ⚠️  Cons: {rec['cons']}")
    
    print("\n" + "=" * 60)
    print("💡 SOLUTIONS FOR MODEL ACCESS")
    print("=" * 60)
    
    solutions = [
        "1. 🔓 Upgrade to Hugging Face Pro ($20/month)",
        "   • Access to all Inference API models",
        "   • Higher rate limits", 
        "   • Priority support",
        "",
        "2. 🏠 Self-hosted deployment:",
        "   • Use Ollama locally for development",
        "   • Deploy your own model on cloud (AWS, GCP, Azure)",
        "   • Use vLLM or TGI for serving",
        "",
        "3. 🔄 Alternative APIs:",
        "   • OpenAI GPT-4 (excellent for legal analysis)",
        "   • Anthropic Claude (very good at following instructions)",
        "   • Google Gemini Pro",
        "   • Groq (fast inference with Llama/Mistral)",
        "",
        "4. 📝 Use available model creatively:",
        "   • Adapt facebook/bart-large-cnn for legal summarization",
        "   • Chain multiple smaller models",
        "   • Use it for document summarization + rule-based classification"
    ]
    
    for solution in solutions:
        print(solution)
    
    print("\n" + "=" * 60)
    print("🚀 IMMEDIATE ACTION PLAN")
    print("=" * 60)
    
    action_plan = [
        "1. 💳 Upgrade to HuggingFace Pro for best experience",
        "2. 🎯 Use Mistral-7B-Instruct-v0.2 as primary model", 
        "3. 🔄 Keep Ollama as local development fallback",
        "4. 📊 Test with smaller models if budget is constrained",
        "5. 🏗️  Consider hybrid approach: HF for production, Ollama for dev"
    ]
    
    for action in action_plan:
        print(action)

def check_huggingface_pricing():
    """Display current Hugging Face pricing information"""
    print("\n" + "=" * 60)
    print("💰 HUGGING FACE PRICING (as of 2024)")
    print("=" * 60)
    
    pricing = {
        "Free Tier": {
            "price": "$0/month",
            "features": [
                "Limited model access",
                "Rate limited API calls", 
                "Basic support",
                "Some models unavailable"
            ]
        },
        "Pro Tier": {
            "price": "$20/month", 
            "features": [
                "Access to all Inference API models",
                "Higher rate limits",
                "Priority support",
                "Early access to new models",
                "Spaces Pro features"
            ]
        },
        "Enterprise": {
            "price": "Custom pricing",
            "features": [
                "Dedicated infrastructure",
                "SLA guarantees", 
                "Custom model hosting",
                "Advanced security"
            ]
        }
    }
    
    for tier, info in pricing.items():
        print(f"\n🏷️  {tier}: {info['price']}")
        for feature in info['features']:
            print(f"   • {feature}")

if __name__ == "__main__":
    search_huggingface_models()
    check_huggingface_pricing()
    
    print("\n" + "=" * 60)
    print("🔗 USEFUL LINKS")
    print("=" * 60)
    print("• HuggingFace Pro: https://huggingface.co/pricing")
    print("• Model Leaderboard: https://huggingface.co/spaces/HuggingFaceH4/open_llm_leaderboard")
    print("• Legal AI Models: https://huggingface.co/models?search=legal")
    print("• Inference API Docs: https://huggingface.co/docs/api-inference/index")
