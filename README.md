if theres a problem run dos2unix on each file

below was written 2025-12-11 --

ok so over 6 october to 8 october I was able to create an animation stsyem with imagemagick (v6), potrace, and ffmpeg that required only drawing on paper and completely side-stepping animation software, at least for drawing. I used it to handle working on Opentoonz because the vectorization, or just the experience drawing on it was terrible, in comparison to Toon Boom, which I had been using for the past 13 years; it was amazing to me, and I could completely retire my Cintiq. Initially when I came across this, I wanted to keep it secret and sell it to companies to make a lot of money. It might be a worthy ... offering ... if I in fact don't, and allow the code to be public.

to run the programs you can test out their functioning by copying one of the scripts into the `demo-mats` folder, and running:
```bash
./pdf-to-[alpha_mov].sh [input].pdf [holds].csv
```

update

full cycle
```bash
./pdf-to-[superimpos].sh [input].pdf [holds].csv [background].{jpg, png}
```

the input is the pdf file and the holds are the number of frame holds per drawing; the scripts are simplified so that the csvs can be raw frame counts

e.g.

```csv
16
12
4
24
```

is what you'll see if you peek into the csv file in the demo folder, and all the numbers are just the amount of frames you have to hold the drawing on the screen for (24 frames per second of course B) ). Great for animations (have fun droppin all those 2s there) and storyboards. you can drop processed drawings into existing software like the venerable Toon Boom products or Opentoonz if you're running one that doesn't output a video (-svg, -png, -png-white; omit [holds].csv from your bash command)
