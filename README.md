# Badge-app
python -m venv .venv
source .venv/bin/activate  
pip install -r requirements.txt

npm start


function editBadge(id) {
    const badges = getLocalBadges();
    const badge = badges.find(b => b.id === id);
    
    if (!badge) {
        showMessage('Badge non trouvé', 'error');
        return;
    }

    currentBadgeId = id;
    document.getElementById('modalTitle').textContent = 'Modifier Badge';
    document.getElementById('nom').value = badge.nom;
    document.getElementById('prenom').value = badge.prenom;
    document.getElementById('valide').value = badge.valide;
    document.getElementById('badgeModal').classList.add('active');
}

function deleteBadge(id) {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce badge?')) return;

    const badges = getLocalBadges();
    const filteredBadges = badges.filter(b => b.id !== id);
    saveLocalBadges(filteredBadges);
    
    showMessage('Badge supprimé avec succès!', 'success');
    loadBadges();
    loadStats();
}

const editDeleteButtons = currentSource === 'local' ? `
    <button class="btn btn-sm btn-primary" onclick="editBadge(${badge.id})" title="Modifier">
        ✏️
    </button>
    <button class="btn btn-sm btn-danger" onclick="deleteBadge(${badge.id})" title="Supprimer">
        🗑️
    </button>
` : '';