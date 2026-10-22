# Disaster Ready – TestFlight-klargjøring

Oppdatert 22. oktober 2026. Dette dokumentet er en test- og publiseringssjekkliste. Ingen arkivering, opplasting eller publisering utføres automatisk.

Endelig automatisert regresjon er grønn: build for testing og 168 av 168 tester besto (151 enhetstester, 15 funksjonelle UI-tester, launch-test og launch-performance-test).

## Forslag til versjonsnotater

Disaster Ready har fått en enklere akuttflyt og bedre støtte når strøm, mobilnett, internett eller satellittjenester kan være utilgjengelige. Viktige råd og personlige planer ligger lokalt på enheten. Forsyningsoversikten viser registrert utstyr og prioriterte mangler for én ukes egenberedskap, med handleliste som kan deles, lagres som PDF eller skrives ut. Den personlige nødplanen kan også opprettes som PDF, og følsomme opplysninger er utelatt som standard.

## Foreslåtte App Store-skjermbilder

1. «Hva trenger du nå?» – de tre primærinngangene uten påstand om sanntidsstatus.
2. «Første handling uten nett» – kombinert strøm- og kommunikasjonsutfall med lagret-på-enheten-status.
3. «Se det viktigste først» – tre prioriterte forsyningsoppgaver og ærlige registrert/anbefalt/mangler-tall.
4. «Din nødplan på enheten» – møteplass, kontaktvei og tydelig skille mellom egne og offentlige opplysninger.
5. «Velg hva du deler» – PDF-arket med sensitive opplysninger avslått.

Ikke bruk skjermbilder som antyder at appen kjenner faktisk strøm-, mobil-, satellitt- eller kringkastingsstatus, eller at den er en offentlig varslingstjeneste.

## Manuell TestFlight-test

- Installer som ny bruker, avslå lokasjon og fullfør de fem oppgavene: finn første handling, finn hjelp uten nett, åpne nødplan, lag handleliste og lag PDF.
- Oppdater en installasjon med eksisterende profil, kontakter, varer og plan. Bekreft at alt innhold fortsatt finnes og kan redigeres.
- Gjenta kald oppstart i flymodus uten Wi-Fi og med Wi-Fi koblet til et nett uten internettilgang.
- Gjenta med tregt nett og bryt et oppslag underveis. Bekreft at siste gyldige data beholdes og at akuttinnhold aldri blir tomt.
- Test uten lokasjonstillatelse, med en simulert feilposisjon og uten GPS-data. Flymodus alene er ikke en GPS-test.
- Kontroller liten iPhone og iPad i stående og liggende retning, lys/mørk visning, Dynamic Type AX5 og VoiceOver.
  - iPhone-kontroller og automatisert tilgjengelighetsaudit består. Ny visuell iPad-simulatorøkt krever en iPad-runtime med iOS 27.0+; de nå installerte iPad-simulatorene bruker iOS 26.5 og støttes ikke av interaksjonsverktøyet. Fysisk iPad-build, UI-tester og rotasjonstest består, men visuell skjermbildekontroll står åpen.
- Åpne norsk, engelsk og thai. Kontroller særlig nødnumre, forbehold, datoer, lange navn og PDF-er over flere sider.
  - Automatisert norsk/engelsk PDF-matrise består. En norsk tresiders og en thai firesiders A4-plan er kontrollert visuelt på første, midtre og siste side uten klipping, manglende sluttinnhold, tegnfeil eller brutte sideskift. Faktisk eksportåpning på fysisk enhet står fortsatt i den manuelle matrisen.
- Prøv utskrift mot en faktisk AirPrint-skriver. Simulatorens «No Printer Selected» dokumenterer bare at systemdialogen åpnes.
- Mål tiden fra kald start til første relevante handling med en person som ikke kjenner navigasjonen.

## Før opplasting

- Øk build-nummeret fra forrige opplastede bygg.
- Velg riktig distribusjonssertifikat og provisioning profile i Xcode.
- Kjør Product > Archive og Validate App.
- Les valideringsresultatet før eventuell Upload to App Store Connect.
- Kontroller personvernerklæring, eksportkrav, aldersgrense, metadata og TestFlight-testinformasjon i App Store Connect.
- Publiser ikke før alle gjenstående manuelle nettverks-, tilgjengelighets- og enhetstester er dokumentert.
