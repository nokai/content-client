function orientationChanged() {
	var e = document.getElementsByTagName('video')[0];
	e.width = (e.width == 768) ? 1024 : 768;
	e.height = (e.height == 768) ? 1024 : 768;
}