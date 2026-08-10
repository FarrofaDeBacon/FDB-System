let gameActive = false;
let cursorX = 0;
let cursorDirection = 1;
let cursorSpeed = 1.2; // % per frame
let timeRemaining = 5.0;
let gameInterval;
let timerInterval;

let zones = {
    common: { start: 10, end: 35, type: 'common' },
    uncommon: { start: 50, end: 65, type: 'uncommon' },
    rare: { start: 80, end: 88, type: 'rare' }
};

$(function() {
    window.addEventListener('message', function(event) {
        let item = event.data;
        if (item.action === "START_MINIGAME") {
            startMinigame(item.time, item.images);
        } else if (item.action === "CANCEL_MINIGAME") {
            closeMinigame();
        }
    });

    document.addEventListener('keydown', function(event) {
        if (!gameActive) return;
        
        // Spacebar
        if (event.code === 'Space') {
            event.preventDefault();
            stopMinigame();
        }
        
        // Escape / Backspace to cancel
        if (event.code === 'Escape' || event.code === 'Backspace') {
            event.preventDefault();
            cancelMinigame();
        }
    });
});

function setupZones() {
    $('#zone-common').css({ left: zones.common.start + '%', width: (zones.common.end - zones.common.start) + '%' });
    $('#zone-uncommon').css({ left: zones.uncommon.start + '%', width: (zones.uncommon.end - zones.uncommon.start) + '%' });
    $('#zone-rare').css({ left: zones.rare.start + '%', width: (zones.rare.end - zones.rare.start) + '%' });
}

function startMinigame(time, images) {
    if (gameActive) return;
    
    timeRemaining = time || 5.0;
    cursorX = 0;
    cursorDirection = 1;
    // Speed varies slightly
    cursorSpeed = 1.0 + Math.random() * 0.5; 
    
    // Set Images
    $('#img-common').attr('src', images.common || '');
    $('#img-uncommon').attr('src', images.uncommon || '');
    $('#img-rare').attr('src', images.rare || '');
    
    setupZones();
    
    $('#minigame-container').show();
    $('#time-display').text(timeRemaining.toFixed(1));
    $('#time-bar').css('width', '100%');
    $('.item-box').removeClass('active');
    
    gameActive = true;
    
    // Cursor loop
    gameInterval = setInterval(() => {
        cursorX += cursorSpeed * cursorDirection;
        if (cursorX >= 100) {
            cursorX = 100;
            cursorDirection = -1;
        } else if (cursorX <= 0) {
            cursorX = 0;
            cursorDirection = 1;
        }
        $('#slider-cursor').css('left', cursorX + '%');
        
        // Highlight active item box based on cursor position
        let hitType = getHitZone(cursorX);
        $('.item-box').removeClass('active');
        if (hitType) {
            $('#box-' + hitType).addClass('active');
        }
    }, 16); // ~60fps
    
    // Timer loop
    let totalTime = timeRemaining;
    timerInterval = setInterval(() => {
        timeRemaining -= 0.1;
        if (timeRemaining <= 0) {
            timeRemaining = 0;
            cancelMinigame(); // Timeout means failure
        }
        $('#time-display').text(timeRemaining.toFixed(1));
        $('#time-bar').css('width', ((timeRemaining / totalTime) * 100) + '%');
    }, 100);
}

function getHitZone(x) {
    if (x >= zones.common.start && x <= zones.common.end) return 'common';
    if (x >= zones.uncommon.start && x <= zones.uncommon.end) return 'uncommon';
    if (x >= zones.rare.start && x <= zones.rare.end) return 'rare';
    return null;
}

function stopMinigame() {
    gameActive = false;
    clearInterval(gameInterval);
    clearInterval(timerInterval);
    
    let hitType = getHitZone(cursorX);
    
    setTimeout(() => {
        closeMinigame();
        $.post('https://illegal-system/minigameResult', JSON.stringify({
            success: hitType !== null,
            tier: hitType
        }));
    }, 500); // Small delay to show where it stopped
}

function cancelMinigame() {
    gameActive = false;
    clearInterval(gameInterval);
    clearInterval(timerInterval);
    
    closeMinigame();
    $.post('https://illegal-system/minigameResult', JSON.stringify({
        success: false,
        tier: null
    }));
}

function closeMinigame() {
    $('#minigame-container').hide();
}
