// 메뉴
const menuButton = document.getElementById('menu-button');
const menuContent = document.getElementById('menu-content');

menuButton.addEventListener('click', function() {
    console.log('click');
    menuContent.classList.toggle('hidden');
});

menuButton.style.cursor = 'pointer';