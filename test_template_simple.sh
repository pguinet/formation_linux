#!/bin/bash

echo "🧪 Test simple des modules 1-3"

cd /opt/github/formation_linux

# Test module 1
echo "📦 Test module 1"
if bash -c 'source scripts/build_formations.sh && generate_individual_module 1'; then
    echo "✅ Module 1 OK"
else
    echo "❌ Module 1 KO"
fi

# Test module 2  
echo "📦 Test module 2"
if bash -c 'source scripts/build_formations.sh && generate_individual_module 2'; then
    echo "✅ Module 2 OK"
else
    echo "❌ Module 2 KO"
fi

# Test module 3
echo "📦 Test module 3"  
if bash -c 'source scripts/build_formations.sh && generate_individual_module 3'; then
    echo "✅ Module 3 OK"
else
    echo "❌ Module 3 KO"
fi

echo "🎯 Test terminé"