// Array of image file paths
const images = [
    "data/images/1.jpg",
    "data/images/2.jpg",
    "data/images/4.jpg",
    "data/images/5.jpg",
    "data/images/6.jpg"
    // Add more image paths as needed
  ];
  
  let currentIndex = 0; // start at the first image
  
  const slideshowImage = document.getElementById("slideshow-image");
  
  function showNextImage() {
    currentIndex = (currentIndex + 1) % images.length; // loop back to 0
    slideshowImage.style.opacity = 0;
  
    // Wait for fade out then change image
    setTimeout(() => {
      slideshowImage.src = images[currentIndex];
      slideshowImage.style.opacity = 1;
    }, 500);
  }
  
  // Change image every 4 seconds
  setInterval(showNextImage, 4000);
  