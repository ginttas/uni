2022-09-22\
Kaunas\
Information Coding Methods

----

digital info: bitai -> baitai -> simboliai -> etc\
kodavimo algoritmai - suglausti info\
dekodavimo algo - sugrzinti i buvuse busena\
Kodavimas nera sifravimas\
Kodavimai gali buti:
* (Nenupostolingas) Lossless - all info is encoded
* (Nuostolingas) Lossy - tik svarbi info yra uzkodojema

#### Run-length (RLE) Coding

Example:
* Original data: TTTTAAAGTTTT
* Encoded data: 4T3A1G4T
* (4T(TTTT) 3A(AAA) 1G(G) 4T(TTTT))
* (DNR encoding)

----

#### Huffman Coding

Leidzia uzkodoti simbolius/domenu bloka pakeiciant ju kode (codeword)\
Kodoti tik tekste esancius imbolius, pagal ju dazni\
e.g. Dazni simboliai uzkodojemi trumpasi bitais, reti simboliai sunaudoje daugiau bitu\
Sis algortimas sukoinstroje Huffman medi - kuyris parodo kaip uzsikodoje simboliai\
Zingsnai
* Apskaicioti daznius
* Sudaryti medi
* Uzkodoti duomenis
* Pirmus du zingsnius galim skipint jeigu medis jau turimas

Kaip zinome kada radom raide? (e.g AB, kda baigesi A?) (OK supratau, eini kol eina eiti pagal kodavima)

Huffman Coding - naudojemas kai info yra nepolygei pasiskirciusi

Dynamic Huffman Encoding - Sukacioje daznius ir Konstroje medi tuo paciu metu kaip ir kodoje (tik viena kart reikai pereiti per faila)\
(Medis sudaromas nuo didziausio iki maziausio)\

----

#### Lempel-Ziv-Welch (LZW) Coding

Turim zodyna kuri su kiekvina iteracija updatinam\
Zodynas - visi imanomi simboliai esantys musu tekste (Simboliu junginai irgi)\
Kuriant zodyna zodynas vis plecias su vis ilgesnais zodziais


----

#### Arithmetic Coding

Sakoma kad pats efektyviauses (generic)\
Generic kodavimo metodas\
Skaiciojem simbolio tikimybe tekste\
e.g.
Input: AGØ
Output: 0.538

----

#### Data Compression Ratio

The efficiency of compression is defined by data compression ratio\
Lossless compression preserves all the information, but, in general, it does not achieve 
compression ratio much better than 2:1\


----

Kodavimai gali buti nestinami
e.g. Huffman_coding(RLE(texst))

Nezinodami apie data geresiause AE

#### Coding Applications

* RLE is used in: GIF, JPEG
* Huffman coding is used in: JPEG, MP3
* LZW coding is applied in: GIF, TIFF, PDF
* Arithmetic coding is used in: Context-adaptive BAC in MPEG AVC and HEVC

----

2022-11-17 | Sound Procesing | Independent Sound Component Analysis | Sugalvoti bent 3 uzdavinius (Ka matosiu)