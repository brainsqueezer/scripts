#!/bin/sh
#Muestra tu sinergia
resultados=$(lynx --dump "http://www.google.com/search?q=%22sinergia+macramental%22" | grep "Results" | head -1 | sed -e "s/.*of about \(.*\) for.*/\1/g")

echo "Habia una vez un meme"
echo "que crecia despacito"
echo "y aunque ${resultados}"
echo "resultados ya tenia"
echo "era revisado a cada momentito."
