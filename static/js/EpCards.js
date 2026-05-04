document.addEventListener('DOMContentLoaded', async () => {
    try {
        const response = await fetch('./data/iframe.json');
        const episodes = await response.json();

        let currentIndex = 0;

        const episodeContainer = document.getElementById('episode-container');
        const episodeTitle = document.getElementById('episode-title');
        const episodeDescription = document.getElementById('episode-description');
        const episodeIframe = document.getElementById('episode-iframe');
        const prevBtn = document.getElementById('prev-btn');
        const nextBtn = document.getElementById('next-btn');

        function loadEpisode(index) {
            const episode = episodes[index];
            episodeIframe.innerHTML = episode.iframe;
            episodeTitle.textContent = episode.title || 'Episode Title';
            episodeDescription.textContent = episode.description || 'Episode description goes here.';
        }

        function nextEpisode() {
            currentIndex = (currentIndex + 1) % episodes.length;
            loadEpisode(currentIndex);
        }

        function prevEpisode() {
            currentIndex = (currentIndex - 1 + episodes.length) % episodes.length;
            loadEpisode(currentIndex);
        }

        

        prevBtn.addEventListener('click', prevEpisode);
        nextBtn.addEventListener('click', nextEpisode);
       

        loadEpisode(currentIndex);
    } catch (error) {
        console.error('Error loading episodes:', error);
    }
});
