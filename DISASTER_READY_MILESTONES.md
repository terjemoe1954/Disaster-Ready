# Disaster Ready – enklere i hverdagen, raskere i krisen

Dato: 22. oktober 2026
Status: Plan for eksisterende app. Kode og skjermbilder er ikke gjennomgått som del av denne planen.

## Oppdrag til Codex

Arbeid i eksisterende Xcode-prosjekt. Les AGENTS.md og prosjektets dokumentasjon først. Undersøk implementasjonen før du velger løsninger. Gjennomfør milepælene nedenfor i rekkefølge, én om gangen. Ikke skriv hele appen på nytt. Bevar brukerdata, eksisterende funksjoner, språk og støttede enheter. Flytt og forenkle presentasjonen fremfor å slette funksjonalitet.

Start med M0 og fortsett med første gjennomførbare milepæl. Etter hver milepæl: oppdater avkryssinger, dokumenter berørte filer, kontroller, kjente feil og neste steg i denne filen. Ikke marker en milepæl fullført før akseptansekriteriene er kontrollert. Fortsett med rutinevalg uten ny godkjenning. Stopp bare ved reelle blokkeringer eller nødvendige destruktive valg. Ikke publiser til App Store eller endre priser som del av dette oppdraget.

## Mål

- Brukeren skal raskt forstå hva som må gjøres nå, og hvor hjelp finnes.
- Første relevante handling skal kunne finnes innen omtrent 10 sekunder i en enkel brukertest.
- Skill tydelig mellom akutt hjelp, forberedelser og personlig nødplan.
- Viktig innhold skal fungere uten nett, konto, skytjenester eller AI.
- Beredskapslageret skal være oversiktlig og overkommelig.
- Legg til et scenario for samtidig bortfall av strøm og elektronisk kommunikasjon, inkludert utilgjengelige satellittjenester.

## Felles kvalitetskrav

Bruk korte setninger, store trykkflater, tydelige overskrifter, god kontrast og støtte for stor tekst og VoiceOver. Ikke bruk bare farge til å formidle status. Unngå skremmende animasjoner og lange tekstvegger. Følg eksisterende språkvalg; nye tekster skal lokaliseres på alle støttede språk. Norske råd og nødnumre må merkes som norske. Engelske tekster betyr ikke at norske tjenester gjelder globalt.

Ingen oppdiktede hjelpesteder, åpningstider, varsler eller løfter om at hjelp er tilgjengelig. Ikke la AI generere sikkerhetskritiske råd under en hendelse. Kildekontroller slikt innhold før levering. Ingen automatisk diagnose av sabotasje, solstorm eller globalt nettutfall basert på telefonens nettstatus.

## M0 – Kartlegg appen og sikre data

- [x] Kartlegg skjermbilder, navigasjon, scenarioer, datamodeller, lagring, synkronisering, eksterne kilder, kjøpslåser, utskrift og språk.
- [x] Lag en funksjonsoversikt med dagens plassering og foreslått ny plassering. Registrer funksjoner som må bevares.
- [x] Finn nettavhengigheter i oppstart og akuttvisning, inkludert skjulte avhengigheter til innlogging, abonnementskontroll, kart, AI og fjerninnhold.
- [x] Registrer eksisterende feil og etabler at prosjektet bygger før endringer. Dokumenter eventuelle forhåndseksisterende byggefeil.
- [x] Sikre en reversibel endringshistorikk i eksisterende git-oppsett. Ikke overskriv brukerens ucommittede arbeid.
- [x] Planlegg nødvendige datamigreringer. Ikke nullstill lager, kontakter eller planer.

Akseptanse: Funksjonsoversikten og konkret implementeringsrekkefølge er dokumentert. Eksisterende data har en plan for bevaring.

### M0-resultat – 22. oktober 2026

#### Teknisk baseline

- Appen er SwiftUI/SwiftData, versjon 1.2 (4), med iPhone og iPad som målfamilier og iOS 26.5 som minimum.
- Før endringer bygget app- og testmålene uten feil med `BuildProject(buildForTesting: true)`.
- Git-grenen er `main` og følger `origin/main`. Ingen sporede filer var endret ved oppstart; denne milepælsfilen var den eneste usporede filen. Den beholdes som arbeidslogg. Ingen commit, reset eller overskriving er utført.
- Det finnes ingen konto, innlogging, abonnement, StoreKit, kjøpslås, analyse-SDK, reklame-SDK, skysynkronisering eller AI-avhengighet.

#### Dagens navigasjon og funksjoner

Appen bruker én `NavigationStack` med fire faner: Oversikt, Plan, Utstyr og Kontakter. Oversikt inneholder akuttmodus, husstandsstatus, anbefalt neste steg, planstatus, MET-varsler, beredskapsstatus og snarveier til offisielle verktøy. Plan-fanen inneholder hendelsesvalg, handlinger, oppholdssted, personlige steder, prioriterte forsyninger, kontakter, roller, meldingsmaler og øvelser. Utstyr inneholder smarte anbefalinger, betalingsberedskap, hjemme-/billager, søk, påminnelser og veiledning. Kontakter inneholder husstandsmedlemmer, eksterne kontakter, egne viktige numre og offisielle norske nødnumre. Innstillinger, profil, personvern, brukerveiledning, backup/import og nullstilling ligger i et ark fra verktøylinjen. Nødplan kan eksporteres som lokal PDF.

#### Scenarioer

Stabile `EmergencyType`-ID-er finnes for `powerOutage`, `flood`, `extremeWeather`, `landslide`, `wildfire`, `houseFire`, `waterOutage`, `evacuation`, `hazardousRelease` og `warOrSecurityIncident`. Alle har bundlet, kildehenvist offline-mal. Eldre ID-er fra 1.0.1 har et eksplisitt kompatibilitetskart. Det nye scenarioet for samtidig bortfall av strøm og kommunikasjon finnes ikke ennå og skal legges additivt til modellen i M3.

#### Data og lagring

| Data | Lagring | Bevaringsregel |
|---|---|---|
| Kontakter, viktige numre, planer, roller og forsyninger | SwiftData, samme fem `@Model`-typer siden tidligere versjoner | Ikke fjern, gi nytt navn til eller endre betydningen av lagrede felt. Nye felt skal være valgfrie eller ha sikre standardverdier. |
| Husstandsprofil | `UserDefaults`, kodet under `householdProfile.v1` | Behold eksisterende dekoderstandarder og synkronisering med `householdMemberCount`. |
| Betalingsberedskap, øvelser og aktiv hendelsesstatus | Separate lokale `UserDefaults`-lagre | Behold nøkler og bakoverkompatibel dekoding. Hendelsesavkryssing i M2 får en egen nøkkel og skal ikke blandes med forsyninger. |
| Språk, utseende, onboarding, meldingsvalg, filtre og påminnelser | `@AppStorage` | Behold eksisterende nøkler. |
| MET-varsler og offentlige tilfluktsrom | Versjonerte filer i Caches | Referansedata kan erstattes; de inngår ikke i brukerbackup og må aldri forveksles med brukerdata. |
| Brukerbackup | JSON, skjema 5 | Behold import av skjema 1–5. Utvid skjema additivt når nye personlige nødplanfelt innføres. |

Det finnes ingen skysynkronisering. Lokal JSON-eksport/import er eneste flyttemekanisme. PDF og JSON kan opprettes uten appnett; valgt Files-/skriverdestinasjon kan ha egne nettkrav.

#### Nettavhengigheter og akuttflyt

- Oppstart, scenarioer, nødplan, kontakter, forsyninger, betalingsberedskap, kilder og PDF krever ikke nett.
- MET bruker `URLSession` mot MetAlerts og faller tilbake til tydelig merket cache eller utilgjengelig tilstand.
- Geonorge bruker `URLSession` for offisielle tilfluktsrom og faller tilbake til tydelig merket cache eller utilgjengelig tilstand.
- Manuelt områdesøk for vær bruker `MKLocalSearch`; Apple Maps og offisielle nettsider er valgfrie eksterne handlinger.
- Lokasjon er valgfri, ettgangs og utløses av brukeren. Ingen koordinater sendes til MET eller Geonorge.
- Akuttmodus leser bundlet veiledning og lokalt lagret plan/kontakter. Den har ingen innlogging, kjøpskontroll, kart-, AI- eller fjerninnholdsport.
- Førstegangs-onboarding vises i dag som fullskjerm etter oppstart og er derfor en navigasjonsrisiko for M1 selv om den ikke krever konto eller tillatelser.

#### Funksjonsoversikt og planlagt plassering

| Funksjon som skal bevares | Dagens plassering | Planlagt plassering |
|---|---|---|
| Akuttmodus, første handling, husstandsstatus | Oversikt / fullskjerm | Primærinngangen «Jeg trenger hjelp nå»; lokale nødnumre og første handling før onboarding. |
| Hendelsesvalg og handlingsråd | Plan og akuttmodus | Hendelsesvelger under «Jeg trenger hjelp nå», felles M2-mal og tydelig lenke til personlig plan. |
| Personlig plan, møteplass, reserveopphold, ansvar, kontakter og øvelser | Plan | Primærinngangen «Min nødplan», med eksisterende redigering og PDF bevart. |
| Lager, smarte anbefalinger, betalingsberedskap, påminnelser og kunnskapsstoff | Utstyr og Oversikt | Primærinngangen «Min beredskap»; detaljkatalog og kunnskapsstoff sekundært. |
| Egne og offisielle kontakter | Kontakter og plan | Nødnumre også direkte i akuttinngangen; full administrasjon under «Min nødplan». |
| MET-varsler, offentlige tilfluktsrom og kilder | Oversikt / verktøyark / plan | Sekundære offisielle verktøy; aldri port for lokale handlinger. |
| Husstandsprofil | Oversikt-snarvei og Innstillinger | Sekundært under «Min beredskap» og Innstillinger; valgfri ved første oppstart. |
| Meldingsmaler og SMS-komponist | Plan | Sekundært under «Min nødplan»; lokalt innhold og systemhandoff bevares. |
| Backup/import, personvern, brukerveiledning, språk og utseende | Innstillinger | Sekundær navigasjon/Innstillinger, uendret datakontrakt. |
| PDF av nødplan | Plan | «Min nødplan»; senere utvidet i M6 med separate, lokale utskrifter. |

#### Datamigreringsplan

1. M1–M2 endrer kun presentasjon og legger eventuell hendelsesstatus i et separat Codable/UserDefaults-lager. Ingen SwiftData-skjemaendring.
2. M3 legger til en ny stabil `EmergencyType`-case og bundlet mal. Eksisterende `scenarioIdentifier`-verdier beholdes ordrett; manglende plan opprettes additivt med dagens `EmergencyPlanMigration`-mønster.
3. Nye personlige felt i M3/M6 legges først i en versjonert, separat Codable-store eller som valgfrie SwiftData-felt med eksplisitt backupstøtte. Ingen eksisterende felt gjenbrukes med ny betydning.
4. Backupskjema økes bare når nye brukerdata faktisk skal eksporteres. Dekoding av skjema 1–5 og alle eksisterende snapshot-felt beholdes.
5. Forsyningsgrupper/handleliste i M5 avledes fra eksisterende `SupplyItem` og stabile anbefalings-ID-er. Egne varer, mengder, pakket-status og kontrollfrister muteres ikke av beregningen.
6. Referansecacher kan migreres eller forkastes separat fordi de ikke er brukerdata; kontakter, planer, profil og lager skal aldri nullstilles som cachehåndtering.

#### Konkret implementeringsrekkefølge

M1 etablerer de tre primærinngangene og gjør onboarding ikke-blokkerende. M2 lager en gjenbrukbar, lokal hendelsesmal og separat lokal avkryssing. M3 legger til det nye stabile scenarioet og personlige offline-felter. M4 formaliserer bundlet veiledningsversjon og tydelig lagret/hentet-status. M5 forenkler forsyningsoversikten og lager en eksplisitt handleliste uten å endre eksisterende varer. M6 samler nødplan og lokale PDF-er med eksplisitt personvernvalg. M7 oppdaterer og kontrollerer kildekontraktene og alle språk. M8 legger til målrettede migrerings-, offline-, navigasjons- og beregningstester og dokumenterer manuell enhetstest uten automatisk publisering.

## M1 – Enkel forside og tydelig navigasjon

- [x] Lag tre primære innganger: «Jeg trenger hjelp nå», «Min beredskap» og «Min nødplan».
- [x] Gjør relevante nødnumre og hjelp lett tilgjengelige uten å kreve onboarding.
- [x] Flytt innstillinger, omfattende kunnskapsstoff og detaljoversikter til sekundær navigasjon.
- [x] Bevar tilgangen til alle eksisterende funksjoner gjennom den nye strukturen.
- [x] La brukeren åpne appen uten å fylle ut husstand, gi lokasjonstilgang eller opprette konto først.

Akseptanse: En førstegangsbruker kan åpne en hendelse og finne første handling innen omtrent 10 sekunder. Ingen tidligere funksjoner er blitt utilgjengelige.

### M1-resultat – 22. oktober 2026

- `Views/PrimaryNavigationSection.swift` legger tre store, lokaliserte og tilgjengelighetsmerkede innganger øverst på forsiden. De åpner eksisterende akuttmodus, Utstyr og Plan uten å endre lagrede data.
- `DisasterDashboardView.swift` viser offisielle landtilpassede nødnumre direkte etter primærinngangene. Automatisk fullskjerm-onboarding ved første oppstart er fjernet; en frivillig introduksjon vises som kort og kan fortsatt åpnes fra Innstillinger.
- Alle fire eksisterende faner, redigeringsflyter, offisielle verktøy, meldingsmaler, backup/import og PDF er bevart. Innstillinger og detaljstoff forblir sekundære.
- `Disaster_ReadyUITests.swift` har tester for ikke-blokkerende første oppstart og ruting fra de nye inngangene til eksisterende Plan/Utstyr.
- App- og testmål bygger uten feil etter endringen. Den nye testen for ikke-blokkerende første oppstart besto. Senere UI-testforsøk nådde ikke appen fordi iOS-simulatoren ikke kunne starte flere prosesser (`maxUserProcs`); Xcode rapporterte disse infrastrukturfeilene som testfeil.
- En separat enhetskontroll forsøkte både iPhone 17 Pro- og iPhone 15 Pro-simulator. Begge ble blokkert før appstart av samme systemgrense. Manuell 10-sekunders brukertest og resterende navigasjonsregresjon gjenstår derfor før endelig akseptanse kan signeres.
- Etter simulatoromstart 22.10.2026 besto begge nye UI-tester. Enhetskontroll bekreftet direkte, ikke-blokkerende førstegangsvisning, tre tappbare primærvalg og korrekt navigasjon til hjelp, beredskap og nødplan. M1-akseptansen er dermed godkjent.

## M2 – Kort og handlingsrettet hendelsesvisning

- [x] Bruk samme mal for alle hendelser: «Gjør dette først», «Finn hjelp», «Neste steg» og «Les mer».
- [x] Vis normalt 3–5 korte prioriterte punkter først. Vesentlig sikkerhetsinformasjon skal ikke gjemmes i «Les mer».
- [x] Bevar utfyllende råd, men åpne detaljer ved behov.
- [x] Vis relevante kontakter og lokalt lagret informasjon uten å vente på nett.
- [x] Gi tydelig vei tilbake til hendelsesvalg og nødplan.
- [x] La eventuell avkryssing av handlinger være lokal og enkel å nullstille for en ny hendelse; ikke bland dette med beredskapslageret.

Akseptanse: Minst én eksisterende hendelse og det nye scenarioet bruker malen. Deretter overføres øvrige hendelser uten tap av viktig innhold.

### M2-status – implementert for eksisterende hendelser, sluttakseptanse ved M3

- `Views/EmergencyModeView.swift` bruker én felles struktur for alle eksisterende hendelsestyper: tre prioriterte handlinger, lokalt tilgjengelig møte-/kontaktinformasjon, neste steg og utvidbare detaljer.
- Handlingsavkryssing ligger kun i visningens lokale `@State`, kan nullstilles eksplisitt og nullstilles automatisk når hendelse byttes. Den endrer verken SwiftData, `UserDefaults`, husstandsstatus eller forsyningslager.
- Hendelsesvelgeren forblir øverst. «Åpne nødplanen min» lukker akuttvisningen og går til eksisterende Plan-fane.
- Alle eksisterende hendelser bruker malen via dagens stabile `EmergencyType` og `EmergencyPlanTemplate`. Det nye scenarioet legges til i M3; først da kan M2s eksplisitte sluttakseptanse signeres.
- Build for testing besto med 0 feil. Simulatorbasert visuell kontroll er fortsatt blokkert av vertsmaskinens prosessgrense.
- Etter simulatoromstart ble alle fire seksjoner funnet og brukt i akuttvisningen. Det nye M3-scenarioet bruker samme mal med totalt fem råd, og vei til Plan ble verifisert. M2-akseptansen er godkjent.

## M3 – Ny hendelse: «Strøm og kommunikasjon borte»

Kort forklaring: «Strøm, mobilnett, internett og satellittjenester kan være utilgjengelige samtidig. Her finner du planen din og råd som er lagret på telefonen.»

### Avgrensning og korrekt fremstilling

- [x] Bruk stabil scenario-ID i tråd med prosjektets modell. Ikke bruk oversatt tittel som datanøkkel.
- [x] Beskriv ekstrem solaktivitet, større ulykker og sabotasje som mulige bakgrunner for omfattende forstyrrelser, med verifiserte fagkilder før publisering. Ikke påstå at én av disse alltid slår ut alle tjenester.
- [x] Scenarioet skal kunne velges manuelt og brukes uansett ukjent årsak. Det skal ikke kreve at brukeren fastslår hva som har skjedd.
- [x] Planlegg for at satellittinternett, satellittmeldinger og satellittbasert posisjonering kan være utilgjengelige eller upålitelige. Ikke forutsett GPS eller fungerende kartposisjon.
- [x] Skill mellom bortfall av toveis kommunikasjon og kringkasting. DAB kan være tilgjengelig selv om mobilnett og internett er nede, men skal ikke loves å fungere.
- [x] Ha et tydelig alternativ: «Jeg får heller ikke inn radio». Da vises lokal nødplan, avtalte møteplasser og lagrede kommunale opplysninger.

### Første skjerm – innholdsutkast som skal kildekontrolleres

Vis inntil fem korte handlingskort:

1. «Sjekk at du og de rundt deg er trygge.» Vis kildekontrollerte råd ved umiddelbar fare. Ikke gi en generell ordre om å gå ut.
2. «Åpne nødplanen din.» Vis avtalte møteplasser og beredskapsvenn, hvis disse er lagret.
3. «Spar telefonbatteriet.» Gjør lokal veiledning tilgjengelig og unngå unødvendige automatiske nettforespørsler. Ikke slå av forbindelser automatisk.
4. «Prøv batteridrevet DAB-radio hvis du har det.» Forklar at mottak og sending kan være berørt. Ikke foreslå nettradio som løsning uten nett.
5. «Se lagrede steder for informasjon og hjelp.» Vis adresse, kilde og dato, med beskjed om at åpning og tilgjengelighet ikke er bekreftet.

- [x] Hvis ingen nødplan eller hjelpesteder er lagret: vis dette ærlig og gi kildekontrollert generell veiledning. Ikke opprett fiktive møtesteder eller anta at nærmeste skole/politistasjon er et bemannet hjelpesenter.
- [x] Når digital kontakt ikke virker: forklar at appen ikke kan formidle nødmeldinger, og vis forhåndslagrede lokale alternativer. Ikke lov at nødnummer virker uten tilgjengelig nett.
- [x] Behold mulighet til å forsøke relevant nødanrop ved reell nød; appens vurdering av internettforbindelse kan ikke avgjøre om tale/nødanrop er mulig.
- [x] Ikke send brukeren til et fysisk sted uten forbehold om trygg ferdsel og lokale myndighetsråd. Avtalte familiemøtesteder er ikke offentlige hjelpesentre.

### Neste steg og forberedelser

- [x] Gi korte veier til eksisterende kildekontrollerte råd om vann, varme, mat, hygiene og personer med særlige behov.
- [x] La familien lagre møteplass og reserveplass, kontaktperson/beredskapsvenn, kommunalt informasjonspunkt og korte veibeskrivelser i tekst.
- [x] Ha plass til individuelle behov, for eksempel strømavhengige hjelpemidler. Ikke generer medisinske behandlingsråd.
- [x] Lag et utskrivbart kort for situasjoner der også telefonen blir tom for strøm.
- [x] Ikke bygg mesh-nett, egen nødmeldingstjeneste eller amatørradiofunksjon i denne milepælen.

Akseptanse: Scenarioet kan åpnes etter full avslutning og ny oppstart uten nett, uten lokasjon og uten satellittposisjon. Alle hovedråd og lagrede planer er tilgjengelige. Tilfellet der radio også er utilgjengelig har en egen tydelig vei.

### M3-resultat – 22. oktober 2026

- Ny stabil ID `powerAndCommunicationsOutage` er lagt til uten å endre eldre ID-er. Den bruker M2-malen med fem lokale handlinger og kan velges manuelt uten årsaksfastsettelse.
- Bundlet tekst skiller mellom ekom og DAB, omtaler ulykke, sabotasje og romvær bare som mulige årsaker, og sier uttrykkelig at satellittjenester/GPS kan være utilgjengelige eller unøyaktige.
- «Jeg får heller ikke inn radio» viser lagret møteplass, reserveplass, beredskapsvenn, kommunalt informasjonspunkt, veibeskrivelse og individuelle behov. Manglende verdier vises som «Ikke angitt», og brukerlagrede steder merkes som ubekreftede.
- Husstandsprofilen har fire nye valgfrie tekstfelt. Bakoverkompatibel `Codable`-dekoding bevarer eldre profiler; backup inkluderer feltene gjennom eksisterende profilpayload. PDF-kortet tar med offlineopplysningene for dette scenarioet.
- Kildegrunnlag kontrollert mot DSBs råd om egenberedskap/informasjon og kommunikasjon, Nkoms veiledning om nødnummer/nødanrop og Kartverkets romværinformasjon. Kildene ligger i `GuidanceSourceRegistry` med kontrollert dato.
- Build for testing besto. 8 målrettede tester besto: 4 for scenario/mal/prioritering og 4 for backup/profilmigrering. Full avslutning/ny oppstart i flymodus og visuell kontroll av radioalternativet gjenstår fordi simulatoren fortsatt er blokkert av vertens `maxUserProcs`-grense.
- Etter simulatoromstart ble scenarioet, alle fem råd, radioalternativet, ærlig «Ikke angitt»-tilstand, ansvarsbegrensninger og navigasjon til valgt nødplan verifisert visuelt. Bundlet innhold var fortsatt tilgjengelig etter ren relansering. Verktøyet manglet en trygg øktlokal nettverksbryter, så faktisk flymodus gjenstår. Én første åpning avsluttet appen med en duplisert iOS 27 Accessibility/WebKit-klasse i simulatorloggen; ingen Swift-feilstakk, og hendelsen lot seg ikke gjenskape etter relansering.

## M4 – Drift uten nett og pålitelig status

- [x] Lever et versjonert grunnsett med viktig veiledning i appen, slik at også en førstegangsstart uten nett fungerer.
- [x] Lagre personlig nødplan og nødvendige kontaktopplysninger lokalt med samme personvernnivå som øvrige følsomme data.
- [x] Gjør sikker oppdatering av veiledning mulig: behold siste gyldige versjon ved feil og avbrudd.
- [x] Ingen blokkerende nettforespørsler, uendelig lastespinner eller gjentatte feilvarsler i akuttflyten.
- [x] Vis «Lagret på telefonen», kilde og sist kontrollert dato. Skill dette fra «Sist hentet».
- [x] Ikke bruk internettstatus som bevis for tilstanden til mobiltelefoni, strømnett, satellitter eller kringkasting. Brukeren velger hendelse; eventuell nettstatus gjelder appens tilkobling.
- [x] Eksterne kart og oppslag skal ha tekstalternativ. Ikke lov frakoblede kart uten at de faktisk finnes og er testet.
- [x] Bruk søk i lokalt innhold hvis søk finnes. Ingen AI- eller skykall skal være nødvendig for første handling.
- [x] Akuttveiledning og lagret nødplan skal være tilgjengelige uten innlogging eller betalingskontroll. Dokumenter eksisterende kjøpsstruktur og gjennomfør uten å endre App Store-priser.

Akseptanse: Ingen kritiske sider blir tomme ved nettfeil. Både fersk installasjon og eksisterende installasjon med lagrede data testes uten nett.

### M4-resultat – 22. oktober 2026

- `OfflineGuidanceCatalog` leverer et komplett, versjonert norsk grunnsett (`2026.10.22.1`) for alle hendelser direkte fra appen. Første handling krever ingen nett-, sky-, AI-, konto- eller betalingskontroll.
- `OfflineGuidanceStore` validerer skjema, land, fullstendige hendelser, stabile mal-ID-er og registrerte kilder før en kandidat skrives atomisk. Ugyldig eller avbrutt innhold erstatter ikke siste gyldige pakke; bundlet pakke er alltid reserve.
- Akuttvisningen viser «Lagret på telefonen», veiledningsversjon, relevante kilder og «Sist kontrollert». Teksten sier uttrykkelig at dette ikke er sanntidsstatus eller «sist hentet», og at appen ikke fastslår tilstanden til strøm, ekom, satellitter eller kringkasting.
- Personlig plan og kontakter bruker fortsatt eksisterende lokal SwiftData/`UserDefaults`-lagring og backup. Ingen innlogging, kjøpsstruktur, abonnement, StoreKit-kode eller App Store-pris finnes eller er endret.
- MET- og Geonorge-oppslag beholder eksisterende siste gyldige cache ved nettfeil. Akuttflyten utfører ingen av disse forespørslene. Eksterne kart/registre har tekstlige søk, adresser og forklaringer; appen lover ikke frakoblede kart.
- Build for testing besto. Fire målrettede tester besto, inkludert komplett bundlet pakke, avvisning av ufullstendig oppdatering med bevart fallback, M3-mal og backup round-trip. Simulator bekreftet statuskortet og fortsatt tilgang til nødhandlinger.
- Faktisk nettfeil/flymodus for både fersk og eksisterende installasjon gjenstår fordi testverktøyet ikke kan slå av simulatornett isolert. Dette beholdes som eksplisitt M8-kontroll og hindrer foreløpig full offline-akseptanse.

## M5 – Oversiktlig beredskap og enklere handleliste

- [x] Behold mål om én ukes egenberedskap for Norge, med kilde og landangivelse.
- [x] Tilpass oversikten til lagrede husstandsbehov; vis hva som finnes før det som mangler.
- [x] Samle innhold i få forståelige grupper: vann, mat, varme/lys, helse/hygiene og informasjon/kontakt.
- [x] Vis inntil tre prioriterte neste oppgaver, med tilgang til full liste.
- [x] Skill anbefalt behov, registrert beholdning og manglende mengde. Unngå dobbelttelling og negative mangler.
- [x] La eksisterende detaljer som holdbarhet, spesialbehov og egne varer være tilgjengelige uten å dominere oversikten.
- [x] Ikke vis «Du er trygg» eller en totalscore som lover sikkerhet. Eventuell fremdrift må forklare hva den måler.
- [x] Handlelisten skal bare inneholde valgte mangler, kunne deles og skrives ut, og bevare brukerens egne endringer.

Akseptanse: Brukeren kan se de viktigste manglene og lage handleliste uten å gå gjennom hele katalogen. Husstandsendringer oppdaterer beregninger uten datatap.

### M5-resultat – 22. oktober 2026

- Ny forsyningsoversikt viser målet om én uke, Norge og DSB-kilde, og forklarer at tellingen gjelder sjekklistepunkter og ikke er et løfte om sikkerhet.
- Beregningen bruker eksisterende husstandsprofil og anbefalingsmotor, dedupliserer stabile anbefalings-ID-er og avgrenser mangler til null. Registrerte varer vises før mangler i gruppene vann, mat, varme/lys, helse/hygiene og informasjon/kontakt.
- Inntil tre prioriterte mangler vises først. Alle fem grupper kan åpnes, mens eksisterende søk, filtre, kontrollfrister, mengder, spesialbehov og egne varer fortsatt finnes i den fulle oversikten.
- Handlelisten inneholder bare mangler brukeren selv har valgt. Valgene lagres med stabile ID-er uten å endre `SupplyItem`, og listen kan deles eller sendes til systemets utskriftsdialog.
- Build for testing besto uten feil. To målrettede tester besto for telling/deduplisering og vedvarende brukerutvalg.
- Simulator bekreftet kilde og tellinger, nøyaktig tre neste oppgaver, alle fem grupper, registrert vare før mangler, valg som overlevde relansering, delingsark, utskriftsark og fortsatt tilgang til det eksisterende inventarsøket. Ingen krasj, tekstkutt eller overlapping ble observert. Simulatoren hadde ingen valgt skriver, som forventet.

## M6 – Personlig nødplan og utskrift

- [x] Samle møteplasser, kontakter, lokale informasjonspunkter og personlige behov i én enkel visning.
- [x] Merk offentlige opplysninger, brukerens egne notater og ubekreftede steder forskjellig.
- [x] Gjør adresse, tekstbeskrivelse, kilde og kontrollert dato tilgjengelig uten nett.
- [x] Lag en kompakt A4-nødplan som normalt får plass på én side. Ved mye innhold: flere leselige sider fremfor avkuttet eller svært liten tekst.
- [x] Lag separat utskrift/PDF av handleliste og relevante hendelsesråd.
- [x] PDF skal kunne opprettes uten nett. Forklar ved behov at selve utskriften krever tilgjengelig skriver/forbindelse.
- [x] La brukeren velge om følsomme personlige opplysninger skal inkluderes i deling/utskrift. Ikke legg ved slike opplysninger automatisk.

Akseptanse: PDF er kontrollert visuelt for lange navn, stor tekst, flere sider og norsk/engelsk. Ingen avkutting. Deling og utskrift er prøvd der miljøet tillater det.

### M6-resultat – 22. oktober 2026

- Planfanen har nå en samlet, offline nødplan med møteplass, evakueringssted, trygt oppholdssted, beredskapsvenn, kommunalt informasjonspunkt, veibeskrivelse og personlige behov. Eksisterende redigeringsflyt og lagrede modeller er uendret.
- Egne opplysninger merkes som «Din opplysning», kommunalt informasjonspunkt som brukerens ubekreftede notat, og bundlet offentlig veiledning vises separat med DSB, kontrollert dato og lagret-på-enheten-status.
- Eksisterende A4-renderer bryter automatisk over til nye leselige sider. Nødplan-PDF inkluderer relevante hendelsesråd og nødnumre; personlige steder, roller, kontakter og passord er av som standard og krever et eksplisitt valg.
- Nødplanen kan både lagres som PDF og sendes direkte til systemets utskriftsdialog. Handlelisten har separat deling, PDF-eksport og utskrift og inneholder fortsatt bare valgte mangler. All PDF-generering skjer lokalt uten nettkall; skriver kan fortsatt kreve tilgjengelig forbindelse.
- Build for testing besto. PDF-test bekreftet at langt innhold gir flere sider. En egen personverntest leste generert PDF og bekreftet at hendelsesråd/nødnummer er med, mens sensitive steder er utelatt som standard.
- Simulator bekreftet samlet visning og klassifiseringer, kilde/dato/offline-status, alle sensitive valg av som standard, aktivering etter eksplisitt valg, PDF-lagringsdialog og utskriftsdialog for både plan og handleliste. Ingen krasj, overlapping eller tekstkutt ble observert ved standard tekststørrelse. Full kontroll med stor tekst og begge språk beholdes i M8-matrisen.
- En målrettet M8-test genererte flersiders nødplaner på norsk og engelsk med svært lange navn. PDFKit fant titler, scenario, sluttmarkør etter det lange navnet, siste råd, nødnummerseksjon og bunntekst i begge dokumentene; ingen testet tekst ble avkuttet. En etterfølgende visuell sluttkontroll av en norsk A4-plan på tre sider besto: det lange navnet ble brutt uten klipping, råd 1–55 fortsatte sammenhengende over begge sideskift, nødnumre og bunntekst var komplette, og alle sider hadde leselige marger.

## M7 – Kilder, språk og kvalitetssikring av råd

- [x] Registrer kilde-URL, utgiver, land, kontrollert dato og innholdsversjon for sikkerhetskritiske råd.
- [x] Kontroller nødnumre og hjelpefunksjoner mot relevante offentlige kilder. Ikke gjenbruk norske numre som globale standarder.
- [x] Kontroller forklaringene om solaktivitet/satellittjenester mot relevant fagmyndighet, for eksempel Nkom og Norsk Romsenter eller tilsvarende primærkilde.
- [x] Bevar allmenne handlingsråd ved ukjent årsak. Ikke presenter scenarioet som en prognose eller bekreftet hendelse.
- [x] Kontroller oversettelser slik at betydningen i sikkerhetsrådene bevares.
- [x] Ikke presenter appen som en offentlig varslingstjeneste eller som godkjent av myndighetene uten dokumentasjon.
- [x] Hvis en kilde ikke kan kontrolleres: dokumenter blokkeringen og hold den aktuelle ubekreftede påstanden utenfor publiserbart innhold.

Utgangskilder, undersøkt ved planlegging 22.10.2026; kontroller aktuelle sider igjen under implementering:

- DSB egenberedskap: https://www.dsb.no/sikkerhverdag/egenberedskap/
- DSB spørsmål og svar: https://www.dsb.no/sikkerhverdag/egenberedskap/ofte-stilte-sporsmal-om-egenberedskap/
- Nkom egenberedskap: https://nkom.no/sikkerhet-og-beredskap/egenberedskap

Kildene støtter egenberedskap ved bortfall og alternative informasjonsveier. De er ikke i seg selv dokumentasjon for at en solstorm vil slå ut alle satellitter eller all kommunikasjon samtidig.

### M7-resultat – 22. oktober 2026

- Alle registrerte norske kilder har nå URL, utgiver, land, kontrollert dato og innholdsversjon `NO-2026.10.22`. Dekoding av eldre lagrede kildepakker uten versjonsfelt er fortsatt støttet.
- DSB-lenken for kommunikasjon er oppdatert til den aktuelle siden «Råd hvis internett og mobilnett ikke virker». DSB og Nkom bekrefter råd om DAB/NRK P1, batteribank, kommunale informasjonspunkter og alternative kontaktmåter, uten garanti om dekning.
- 110, 112 og 113 er kontrollert mot DSB, Politiet, Helsenorge og Nkom. 116 117 forblir tydelig klassifisert som legevakt og ikke nødnummer. Norske numre leveres fortsatt bare av landkonfigurasjonen `NO`.
- Kartverket støtter at romvær kan forstyrre GNSS og gi manglende eller unøyaktig posisjon. Direktoratet for romvirksomhet er lagt til som egen primærkilde for mulige virkninger på satellitter, kommunikasjon, GPS og kraft. Teksten beskriver dette som muligheter og sier uttrykkelig at appen ikke fastslår årsak eller status.
- Thai String Catalog ble kontrollert gjennom Xcodes lokaliseringsflyt. 13 manglende nøkler for det kombinerte utfallet ble oversatt med bevarte forbehold; katalogen har nå null uoversatte thai-nøkler. Norsk, engelsk og thai ble deretter kontrollert i simulatoren.
- Build for testing besto. Tre målrettede tester besto for komplett kildekontrakt, scenarioets kildegrunnlag og sikkerhetsforbehold på alle språk.
- Simulator viste alle fem handlinger, de fire spesifikke kommunikasjons-/romværkildene, lokalisert kontrollert dato og ansvarstekster uten avkutting. Nødnumrene var korrekt adskilt. Offisielle dokumenttitler beholdes på myndighetens originalspråk; forklaringer og metadataetiketter lokaliseres. Ett thai-datoformat i planoversikten ble rettet etter kontrollen.

## M8 – Test på enheter og klargjør for TestFlight

- [x] Kjør relevante eksisterende tester og bygg for støttede plattformer. Legg til målrettede tester for migrering, lokale reservedata, mengdeberegninger og kritisk navigasjon der det trengs.
- [ ] Test flymodus uten Wi-Fi, tilkoblet Wi-Fi uten internett, tregt nett og avbrutt innholdsoppdatering.
- [x] Test kald oppstart uten nett, uten lokasjonstillatelse og med feil/manglende posisjon. Flymodus alene beviser ikke at GPS er utilgjengelig; test dette separat med testdata eller avhengighetsinjeksjon.
- [ ] Test ny installasjon uten profil, eksisterende data etter oppdatering, og midlertidig utilgjengelig synkronisering.
- [x] Verifiser at scenarioet ikke krever fungerende radio, satellittmeldinger eller nettsider.
- [ ] Test liten iPhone, stor skrift, VoiceOver, mørk/lys visning og iPad hvis appen allerede støtter iPad.
- [x] Gjennomfør fem oppgaver: finn første handling; finn hjelp uten nett; åpne nødplan; lag handleliste; lag PDF.
- [ ] Mål tidsbruk for første handling med en bruker som ikke kjenner den nye navigasjonen.
- [x] Kontroller alle funksjonene fra M0 mot ny plassering. Ingen viktige funksjoner eller brukerdata skal være borte.
- [x] Oppdater brukerveiledning og forslag til versjonsnotater. Lag forslag til screenshots som viser enkelheten; ingen oppdiktet sanntidsstatus.
- [x] Oppsummer hva som er testet, hva som gjenstår og eventuelle blokkeringer før TestFlight. Ikke kall en test bestått dersom miljøet ikke støtter den.

Akseptanse: Relevant bygg og kontroller er bestått, eller konkrete blokkeringer er oppgitt. Brukeren får en kort liste for manuell TestFlight-test. Ingen automatisk publisering.

### M8-resultat – 22. oktober 2026

- Build for testing besto etter Xcode-omstart, også med iPad som kvalifisert mål. Appmålet støtter iPhone og iPad, generert launch screen, alle fire iPad-retninger og har ingen fullskjermbegrensning. Kildekontroll fant ingen bruk av eldre skjerm-, orienterings- eller idiom-API-er som låser layouten.
- Hele enhetstestsuiten besto: 151 av 151 tester. Én kildeforventning ble oppdatert fordi M7 la Direktoratet for romvirksomhet til det kontrollerte kildegrunnlaget. Migrering, backup, offline-reserve, mengdeberegninger og PDF-personvern er dekket.
- Build for testing og fem representative UI-tester besto senere på en fysisk iPhone 15 Pro. En full enhetskjøring avdekket at eksplisitt engelsk kunne slå opp norsk tekst når telefonens aktive språk var norsk; `LocalizationSupport.swift` bruker nå valgt språkpakke direkte. De fire berørte språk-/sikkerhetstestene og den tidligere ustabile husstands-/betalingsflyten ble kjørt på nytt på telefonen og besto, 5 av 5.
- Fem representative UI-tester besto etter at hjemmesidens tilgjengelighets-ID ble flyttet fra hele kortet til overskriften. Dermed overskriver den ikke lenger ID-ene til kontrollene i den sammenleggbare «Status og snarveier»-seksjonen. Førstegangsvalg, primærnavigasjon, hendelsesplan, hjemmesnarveier og lokalisering på engelsk, norsk og thai er grønne. Tre ekstra hjemmesnarveitester besto også.
- På liten iPhone-simulator ble appen relansert og fem oppgaver gjennomført uten krasj eller datatap: åpne en meningsfull første handling, finne lokalt lagret hjelp, åpne personlig plan, velge handlelistevare og lagre PDF. Kombinert strøm-/kommunikasjonsutfall viste fem lokale råd, versjon, kilde, kontrollert dato og forbehold uten krav til radio, satellittmelding, GPS eller nettside. Standard skrift i stående og liggende retning viste ingen observert tekstkutt eller overlapping.
- Dynamic Type-kildegjennomgang besto etter at en fast énlinjegrense ble fjernet og ikonbredden gjort skalerbar. En senere kjøring bekreftet faktisk AX5 på iPhone 17 Pro i portrett og landskap. Den avdekket at systemets scenario-Picker klippet valgt verdi; kontrollen ble erstattet med en selvstørrelsende meny som skjuler det dekorative ikonet ved tilgjengelighetsstørrelser. Retest viste hele scenarioverdien innenfor kontrollen, og en planhandling kunne rulles helt over fanelinjen og aktiveres i landskap. Dynamic Type-verdict er PASS. Mørk og lys visning ble deretter valgt gjennom appens egen Appearance-innstilling ved standard tekststørrelse. System → Dark → Light skiftet palett umiddelbart i samme prosess; Overview og Plan hadde lesbar kontrast uten observert tekstkutt, overlapping eller feil temafarger. VoiceOver-kildegjennomgang ga PASS: standardkontroller har tekstetiketter, representative ikonknapper har menneskelesbare etiketter, hovedseksjoner har overskriftssemantikk, og ingen egendefinerte trykkgest-kontroller mangler knappetype. En ny simulatorøkt bekreftet etiketter og valgt-status i tilgjengelighetshierarkiet for alle faner, primærvalg og nødanrop. Faktisk VoiceOver-sveip/rotor gjenstår; hierarkiet antyder mulig redundant annonsering av enkelte SF Symbols og veiledningsversjonen som bør kontrolleres da.
- Fysisk `Terje sin iPad 10` ble valgt som mål og build for testing besto uten feil. Fem representative UI-tester ble kjørt på iPad-en. Førstegangsvisning og lokalisering besto direkte; iPadOS 27s flytende fanelinje eksponerte faner som nestede celler i stedet for klassiske `TabBar`-knapper. UI-testene bruker nå et plattformuavhengig oppslag i tilgjengelighetshierarkiet, og de tre berørte navigasjonstestene besto etter rettingen. En egen rotasjonstest besto på fysisk iPad og bekreftet primærhjelp og akuttmodus gjennom landskap og tilbake til portrett. Interaksjonsverktøyet støtter ikke fysiske iOS/iPadOS-enheter, så automatiske skjermbilder og visuell inspeksjon av layouten gjenstår. Faktisk flymodus, Wi-Fi uten internett, tregt nett, kaldstart uten lokasjon/GPS, fersk kontra oppgradert installasjon og midlertidig synkfeil kan heller ikke styres sikkert i dette miljøet. Disse kontrollene står åpne.
- Med fysisk iPad koblet til med kabel, flymodus aktivert og Wi‑Fi slått av besto en kald UI-teststart. Førstegangsvisningen var ikke blokkert, primærinngangen til akuttmodus åpnet, og akuttvisningens `offlineGuidanceStatus` bekreftet at den bundlete veiledningen var tilgjengelig. Dette dekker flymodus uten Wi‑Fi for lokal akuttveiledning; Wi‑Fi uten internett, tregt/avbrutt nett, eksplisitt manglende GPS og oppgradert installasjon står fortsatt åpne.
- Den samme kaldstarttesten nullstiller nå bare appens lokasjonsautorisasjon med XCUIAutomation før oppstart. Den besto på fysisk iPad uten lokasjonstillatelse og uten nett, samtidig som lokale nødvalg og bundlet veiledning var tilgjengelige. Ingen planer, kontakter eller lagerdata ble slettet.
- `ShelterLocationProvider` validerer nå GPS-resultatet før det publiseres. Tomme resultater, NaN og koordinater utenfor gyldig bredde-/lengdegrad avslutter forespørselen med lokal «posisjon utilgjengelig»-tilstand i stedet for å starte nettforespørsel eller bli stående i lastetilstand. Tre målrettede tester for manglende, ugyldig og gyldig posisjon besto. Dermed er kaldstart uten nett/lokasjon og separat feil-/manglende-GPS-kontroll dekket.
- En automatisert XCUIAccessibility-revisjon består nå både Oversikt og akuttmodus for kontrast, elementdeteksjon, treffområder, tilstrekkelige beskrivelser og egenskaper. Revisjonen avdekket og rettet lav kontrast i primærvalg, offisiell kontaktinformasjon, anropsknapper, offline-status og første handlinger. Gjennomsiktige kortflater ble gjort målelige med adaptiv systembakgrunn, og akuttmodusens lukkeknapp ble flyttet ut av verktøylinjens glasslag til en tydelig svart/hvit knapp i innholdet. Testresultat: 1 av 1 besto på iPhone 17 Pro-simulator. Kontrastverdict er PASS; faktisk VoiceOver-sveip/rotor på fysisk enhet gjenstår.
- Etterfølgende hierarkikontroll rettet de konkrete VoiceOver-risikoene fra runtime-verifikasjonen: «Done» er 44,3 punkter høy, scenariovelgeren er 44,0 punkter høy og bred, og veiledningsversjon med verdi er ett kombinert toppnivåelement i stedet for to overlappende fokusmål. Ny XCUIAccessibility-test og ny simulatorinteraksjon besto uten krasj, klipping, overlapping eller synlige kontrastfeil. VoiceOver-kildeverdict er PASS; fysisk sveiperekkefølge og rotor er fortsatt en manuell TestFlight-kontroll.
- Ny visuell iPad-simulatorøkt kunne ikke startes: Xcode har kvalifiserte iPad-modeller, men de er installert med iOS 26.5, mens Device Interaction krever iOS 27.0 eller nyere. Verktøyets egen enhetsliste inneholder bare iPhone-simulatorer med iOS 27.0. Ingen skjermbilder eller hierarkier ble derfor produsert, og kontrollen er fortsatt åpen. Aktivt mål ble satt tilbake til iPhone 17 Pro; ingen kode eller data ble endret.
- Thai PDF ble deretter kontrollert visuelt med en firesiders A4-plan og lange thai-navn/råd. Thai-tegn og diakritiske tegn rendret korrekt, lange felt og råd brøt uten klipping, innholdet fortsatte over sideskiftene, og siste side beholdt råd 55, alle tre norske nødnumrene og lokalisert bunntekst med gode marger. Ingen rendererendring var nødvendig.
- Endelig regresjon etter tilgjengelighetsrettinger og filopprydding besto. Build for testing var grønt, alle 151 enhetstester besto, alle 15 funksjonelle UI-tester besto, og både separat launch-test og launch-performance-test besto etter en ren Xcode-omstart: totalt 168 av 168 tester uten feil eller hoppede tester.
- Brukerveiledningen har nye avsnitt om lokal nødveiledning, personlig plan/PDF og handleliste på norsk, engelsk og thai. `TESTFLIGHT_READINESS.md` inneholder versjonsnotater, fem screenshot-forslag, manuell TestFlight-matrise og sjekkliste før opplasting. Ingen archive eller publisering er utført.

## M9 – Enkel navigasjon og realistisk evakuering

Status: Planlagt. Skal ikke implementeres før brukeren uttrykkelig ber om å starte M9 etter egen gjennomgang og samtale med husstanden.

Mål:

- Gjør forsiden enda klarere, enklere og mer systematisk med få, tydelige lenker og pene, gjenkjennelige ikoner.
- La brukeren finne riktig handling raskt og gå gjennom nødvendige punkter med minst mulig lesing og navigasjon, også under stress.
- Skill tydelig mellom utstyr som skal lagres hjemme for én ukes egenberedskap og en liten, realistisk utrustning som kan tas med ved evakuering.
- Unngå at evakueringslisten foreslår urealistiske mengder som 60 liter vann, mat for en hel uke, flere store soveposer eller omfattende kokeutstyr.
- Ta utgangspunkt i det en vanlig husstand sannsynligvis allerede har, med bare nødvendige og forklarte tillegg.
- Tilpass anbefalingene til husstandens faktiske bæreevne. En husstand med en eldre person, et barn/ungdom eller personer med redusert styrke skal få en kortere og lettere plan, ikke bare samme liste fordelt på flere personer.
- Prioriter ved evakuering: telefon og strøm, medisiner og hjelpemidler, legitimasjon/nøkler/kontaktinformasjon, litt drikke og lett mat for reisen, lette varme klær/regnvern, liten førstehjelpspakke og lykt.
- Merk tungt hjemmeutstyr tydelig som noe som normalt skal bli igjen ved evakuering.
- Vurder en enkel visning eller arbeidsflyt med skillet «Bli hjemme» og «Evakuer lett», uten å fremstille appens råd som en erstatning for myndighetenes instrukser.
- Bevar eksisterende brukerdata, offline-funksjon, sikkerhetsforbehold og tilgjengelighet. Ingen lagringsmodell skal endres uten en dokumentert migreringsplan.

Akseptanse før M9 kan kalles fullført:

- Forsiden er visuelt ryddig og kan forstås raskt av en ny bruker.
- Kritiske handlinger nås med få trykk og har tydelige ikoner og korte tekster.
- Hjemmelager og evakueringsutstyr kan ikke forveksles.
- Evakueringslisten er lett nok til å være praktisk for den registrerte husstanden og viser tydelig hva som må prioriteres eller bli igjen.
- Forslagene er gjennomgått med brukeren etter at dagens app er testet på iPhone og iPad.
- Relevante enhets-, UI-, tilgjengelighets- og migreringstester består.

## Arbeidslogg – fylles ut av Codex

| Milepæl | Status | Endringer/filer | Kontroller og resultat | Gjenstående |
|---|---|---|---|---|
| M0 | Fullført 22.10.2026 | `DISASTER_READY_MILESTONES.md` – baseline, funksjonskart, nett-/datalagringskart og migreringsplan. Ingen produksjonskode eller brukerdata endret. | App- og testmål bygget før endringer uten feil. Git kontrollert: ingen sporede lokale endringer. Ingen konto-, kjøps-, sky- eller AI-avhengighet funnet. | Start M1 med ny primærnavigasjon og ikke-blokkerende førstegangsbruk. |
| M1 | Fullført 22.10.2026 | `Views/PrimaryNavigationSection.swift`, `DisasterDashboardView.swift`, `Disaster_ReadyUITests.swift`. Ingen datamodeller eller lagringsnøkler endret. | Build for testing bestått, 0 feil. 2 nye UI-tester besto. Simulator bekreftet ikke-blokkerende start, tre tappbare valg og korrekt navigasjon. | Ingen. |
| M2 | Fullført 22.10.2026 | `Views/EmergencyModeView.swift`, `DisasterDashboardView.swift`. Kun visningslokal handlingsstatus; ingen datamigrering eller nye persistente nøkler. | Build for testing bestått. Simulator bekreftet alle fire seksjoner, fem M3-råd og vei til nødplan. | Ingen. |
| M3 | Implementert – faktisk flymodus gjenstår | `EmergencyPlanningModels.swift`, `NorwayEmergencyTemplates.swift`, `EmergencyLocalizationResources.swift`, `HouseholdProfile.swift`, `HouseholdProfileEditor.swift`, `EmergencyModeView.swift`, `GuidanceSourceRegistry.swift`, `SupplyPrioritizer.swift`, `PaymentPreparedness.swift`, `FamilyPlanPDFSupport.swift`, dashboard og tester. Nye profilfelt er valgfrie og bakoverkompatible. | Build for testing og 8 målrettede tester besto. Simulator bekreftet scenario, fem råd, radioalternativ, lokale tomtilstander, ansvarsbegrensninger, Plan-ruting og ren relansering. | Test eksplisitt med flymodus/globalt nett avslått når dette kan gjøres kontrollert. Følg med på én ikke-reproduserbar iOS 27 Accessibility/WebKit-simulatoravslutning. |
| M4 | Implementert – faktisk offline-akseptanse gjenstår | `Data/OfflineGuidanceStore.swift`, `Views/OfflineGuidanceStatusSection.swift`, `EmergencyModeView.swift`, planmodellens `Sendable`-konformans og tester. Ingen eksisterende brukerdata eller kjøpsoppsett endret. | Build for testing bestått. 4 målrettede tester besto. Simulator bekreftet versjon, kilde, kontrollert dato, statusforklaring og tilgjengelige nødhandlinger. | Test fersk og eksisterende installasjon med faktisk nettfeil/flymodus i M8. |
| M5 | Fullført 22.10.2026 | `Models/SupplyCoverageModels.swift`, `Views/PreparednessSupplyOverviewSection.swift`, `SmartSupplyModels.swift`, dashboard og tester. Ny lagringsnøkkel gjelder bare valgte anbefalings-ID-er; eksisterende `SupplyItem`-data muteres ikke. | Build for testing bestått. 2 målrettede tester besto. Simulator bekreftet tre neste oppgaver, fem grupper, registrert før mangler, vedvarende valg, deling, utskriftsdialog og eksisterende inventarsøk. | Ingen. |
| M6 | Fullført 22.10.2026 – faktisk AirPrint gjenstår som enhetstest | `Views/PersonalEmergencyPlanOverviewSection.swift`, `FamilyPlanPDFSupport.swift`, `PreparednessSupplyOverviewSection.swift`, `EventAwareMyPlanView.swift` og tester. Ingen lagringsmodell eller eksisterende brukerdata endret. | Build for testing bestått. PDF flerside- og personverntester besto. PDF-matrisen bekreftet norsk og engelsk, svært lange navn, flere sider og bevart sluttinnhold. Visuell kontroll av første, midtre og siste side i en norsk tresiders A4-plan besto uten klipping eller brutte sideskift. | Prøv utskrift mot en faktisk AirPrint-skriver; simulatorens systemdialog er allerede bekreftet. |
| M7 | Fullført 22.10.2026 | `GuidanceSource.swift`, `GuidanceSourceRegistry.swift`, `NorwayEmergencyTemplates.swift`, thai i `Localizable.xcstrings`, lokalisert plan-dato og tester. Ingen brukerdata eller lagringsnøkler endret. | Offentlige primærkilder kontrollert på nytt. Build for testing og 3 målrettede tester besto. Simulator kontrollert på norsk, engelsk og thai; kildekort, forbehold og norske nummer var korrekte. | Ingen ubekreftede påstander eller blokkerte kilder. |
| M8 | Implementert og delvis verifisert – manuell matrise gjenstår | `ReleasePrepSections.swift`, `Views/EmergencyModeView.swift`, `Views/EventAwarePlanSections.swift`, `Views/HomeDashboardSections.swift`, `LocalizationSupport.swift`, enhets-/UI-tester, `TESTFLIGHT_READINESS.md` og denne arbeidsloggen. Ingen datamodell, lagringsnøkkel eller brukerdata endret. | Build for testing besto på fysisk iPhone 15 Pro og fysisk iPad. Endelig simulatorregresjon besto med 168/168 tester: 151 enhetstester, 15 funksjonelle UI-tester, launch-test og launch-performance-test. Fem representative UI-tester besto på både iPhone og iPad etter plattformuavhengig fanesøk; egen fysisk iPad-rotasjonstest besto. Fem kjerneoppgaver besto manuelt på liten iPhone. Faktisk AX5 portrett/landskap og runtime-bytte mellom mørk/lys besto; Dynamic Type- og VoiceOver-kildeverdict er PASS. | Før archive/TestFlight: kontroller iPad-layout visuelt, VoiceOver-sveip/rotor, ukjent-bruker-tid og resterende nett-/installasjonsmatrise. Se `TESTFLIGHT_READINESS.md`. |
| M9 | Planlagt – avventer brukerens gjennomgang | Ingen kodeendringer. Krav er dokumentert for enkel forside, rask navigasjon og realistisk skille mellom hjemmeberedskap og lett evakuering tilpasset husstandens bæreevne. | Ikke startet. | Brukeren tester dagens app på iPhone og iPad, snakker med husstanden og supplerer eventuelle ønsker før oppstart. |
