function nuc=presubBackground_self(nuc,backdiskrad)

nucbgi=imopen(nuc,strel('disk',backdiskrad));
nuc=imsubtract(nuc,nucbgi);
