# Content-sensitive image cropping

Basierend auf "entropy-based" cropping, d.h. basierend auf dem Informationsgehalt (hier: der Pixel) einen Schnittbereich automatisch wählen.

## Interessante Ergebnisse

### Fall 1

Hinweis: In diesem speziellen Beispiel wird der Alphakanal von MATLAB nicht verarbeitet und erscheint schwarz.

`ncrop3.m` mit `6A6E132456CE9AA651058B1608B77052B4B5E10F58EDD38ABE14B0CD46891A1D.png`, Sobel X+Y und Threshold = `0.75`.