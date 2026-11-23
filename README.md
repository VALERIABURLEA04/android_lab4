# GemStore · Laboratorul 4 · Varianta 1

Aplicație Flutter pentru Web și Android. Ecranul **Homepage** afișează catalogul GemStore, iar ecranul **Product** prezintă galeria, prețul, culorile, mărimile disponibile, descrierea, ratingul, recenziile și produsele similare.

## Deschiderea în Visual Studio Code și rularea Web

1. Instalează Flutter SDK, Chrome și extensiile **Flutter** și **Dart** din Visual Studio Code. Deschide în VS Code folderul `gemstore_lab4`, cel care conține `pubspec.yaml`.
2. Rulează `flutter doctor` și `flutter pub get` într-un terminal VS Code.
3. Pornește proxy-ul local într-un terminal și lasă-l deschis:

```powershell
dart run tool/dev_proxy.dart
```

4. În alt terminal, pornește aplicația în Chrome:

```powershell
flutter run -d chrome
```

Poți selecta dispozitivul **Chrome** din bara de jos a VS Code și apăsa **F5**, cu proxy-ul local deja pornit. Pentru o compilare Web rulează `flutter build web`; rezultatul este în `build/web`. Pentru o publicare pe un server, configurează un API care permite CORS sau un proxy găzduit și indică URL-ul său prin `flutter build web --dart-define=API_BASE_URL=https://adresa-proxy/lab2026/v1/`. URL-ul trebuie să se termine cu `/`. Fără `API_BASE_URL`, versiunea Web folosește proxy-ul local pe portul 8081. Endpointul original nu trimite antetul CORS necesar cererilor directe din browser.

## Deschiderea și rularea proiectului pe Android

1. Instalează Flutter SDK și adaugă directorul `flutter/bin` în `PATH`.
2. Instalează Android Studio. Din **SDK Manager**, instalează Android SDK, Platform-Tools, Command-line Tools și Android Emulator. Pentru rularea din IDE, instalează și pluginul **Flutter** din **Settings → Plugins**.
3. Rulează `flutter doctor` într-un terminal. Dacă semnalează licențe Android neacceptate, rulează `flutter doctor --android-licenses` și verifică din nou cu `flutter doctor`.
4. Extrage complet arhiva ZIP. În Android Studio, alege **Open** și selectează folderul `gemstore_lab4`, cel care conține `pubspec.yaml`.
5. Din **Device Manager**, creează și pornește un emulator Android. Poți folosi și un telefon cu depanarea USB activată. Așteaptă să se încarce ecranul Android.
6. Deschide terminalul din Android Studio în folderul proiectului și rulează comenzile de mai jos. Înlocuiește `emulator-5554` cu ID-ul Android afișat de `flutter devices`.

```powershell
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Poți porni și din Android Studio. Selectează dispozitivul Android, deschide `lib/main.dart` și apasă **Run ▶**. Aplicația are nevoie de internet pentru a încărca datele V1. Dacă apare o eroare de conexiune, verifică internetul emulatorului și apasă **Try again**. [Configurarea Flutter pentru Android](https://docs.flutter.dev/platform-integration/android/setup) · [Flutter în Android Studio](https://docs.flutter.dev/tools/android-studio)

APK-ul debug este disponibil separat. Pe un emulator pornit sau un telefon conectat, îl poți instala cu `adb install -r .\GemStore-Lab4-Varianta1.apk` din folderul care conține APK-ul, apoi deschizi aplicația **GemStore**.

## Etapele de implementare

1. **Analiza cerințelor.** Am analizat cadrele Homepage și Product din Figma și răspunsurile JSON ale celor două endpointuri V1. Am identificat câmpurile disponibile în catalog și în fișa Sportwear Set.
2. **Clean Architecture.** Am definit entitățile, contractul `CatalogRepository` și cazurile de utilizare în `lib/domain`. Implementarea HTTP stă în `lib/data`, iar ecranele și starea interfeței în `lib/presentation`.
3. **HTTP asincron.** Am implementat cele două cereri GET cu `package:http` și am legat clientul, repository-ul și cazurile de utilizare în `lib/main.dart`.
4. **Serializarea JSON.** Am modelat răspunsurile în DTO-uri, am generat `fromJson` și `toJson` cu `json_serializable` și am convertit DTO-urile în entități folosite de interfață.
5. **Interfața Flutter.** Am construit nativ ecranele, pictogramele și componentele reutilizabile. Fotografiile Figma sunt afișate după rol și ID, cu URL-ul din API ca rezervă.
6. **Navigarea către produs.** La apăsarea unui card se păstrează fotografia, numele și prețul produsului selectat. Fișa primită de la server completează ecranul când ID-ul coincide.
7. **Încărcarea și erorile.** Am implementat indicatorul de progres, reîncărcarea catalogului și **Try again** pentru erorile de rețea, de server sau de format.
8. **Coșul.** Apăsarea **Add To Cart** pentru Sportwear Set adaugă selecția și deschide **Shopping bag** cu o confirmare. Coșul se poate redeschide din meniu. Dacă produsul selectat nu are opțiuni de cumpărare în API, butonul afișează un mesaj explicativ.
9. **Verificarea.** Am verificat testele Flutter și compilarea Web. Rularea în browser necesită proxy-ul local deoarece API-ul nu permite CORS.

## Fluxul datelor

```text
FeedPage / ProductPage
  → GetFeed / GetProductDetails
  → CatalogRepository
  → RemoteCatalogRepository
  → CatalogRemoteDataSource
  → HTTP GET
  ← JSON → DTO (fromJson) → entitate Domain → interfață
```

| Strat | Responsabilitate |
| --- | --- |
| **Presentation** | Ecrane, stări asincrone, selecții și componente reutilizabile precum `AsyncContent`, `ProductRail` și `CatalogPhoto`. `ShopSession` păstrează coșul, favoritele și recenziile locale pe durata sesiunii. |
| **Domain** | Entități, cazuri de utilizare, erori tipizate și interfața `CatalogRepository`. Stratul folosește numai Dart. |
| **Data** | Cererile HTTP, decodarea UTF-8 și JSON, DTO-urile, transformarea lor în entități și implementarea repository-ului. |

`main.dart` construiește clientul HTTP și injectează repository-ul în aplicație. `json_serializable` generează metodele `fromJson` și `toJson`. Fișierul generat este inclus în proiect. Comanda de regenerare este `dart run build_runner build`.

| Cerere | Conținut |
| --- | --- |
| [GET /lab2026/v1/feed](https://test-api-jlbn.onrender.com/lab2026/v1/feed) | Categorii, banner, produse, recomandări și colecții. |
| [GET /lab2026/v1/feed/details](https://test-api-jlbn.onrender.com/lab2026/v1/feed/details) | Fișa completă pentru produsul `p003`, Sportwear Set. |

Aplicația afișează progresul încărcării, tratează timeoutul, lipsa conexiunii, răspunsurile HTTP nereușite și datele JSON invalide. **Try again** repetă cererea. Catalogul se poate reîncărca și prin tragere în jos.

## Demonstrație

1. Derulează catalogul și glisează orizontal în **Feature Products**.
2. Deschide **Sportwear Set** pentru a declanșa apelul de detalii. Schimbă fotografia și culoarea. Mărimile S și M sunt inactive conform răspunsului API.
3. Extinde descrierea, consultă recenziile și apasă **Add To Cart**. Coșul se deschide imediat și confirmă produsul adăugat. Îl poți redeschide și din **Menu → Shopping bag**.
4. Pentru a demonstra eroarea, oprește conexiunea și reîncarcă. Restabilește conexiunea și apasă **Try again**.

Fiecare card deschide ecranul Product cu fotografia, numele și prețul produsului selectat. Serviciul livrează fișa completă doar pentru Sportwear Set. Pentru celelalte articole, secțiunile fără date sunt marcate ca indisponibile, iar apăsarea butonului de coș explică lipsa opțiunilor de cumpărare. Categoriile se pot selecta vizual. API-ul nu asociază produsele cu categoriile și furnizează o singură imagine de banner. Favoritele, coșul și recenziile adăugate în aplicație au efect local în sesiune. Endpointurile furnizate sunt de citire.

Interfața a fost comparată pe Android cu cadrele Figma **Homepage** (375 × 1714) și **Product** (375 × 1818). Dosarul `assets/figma` conține exclusiv cele 17 fotografii originale. Ecranele, cardurile, textele, controalele și spațierea sunt construite cu widgeturi Flutter. Pictogramele folosesc `CustomPainter` cu geometrie definită în Dart, respectiv `Icon` pentru simbolurile Material.

Prezentarea caută fotografiile în manifestul Flutter folosind rolul imaginii și ID-ul V1, de exemplu `assets/figma/product-p003.png`. Dacă fișierul lipsește, afișează URL-ul din API. Fișierul `assets/photo_framing.json` conține doar coordonatele de decupaj pentru carduri. Catalogul și disponibilitatea provin din API. Galeria începe cu fotografia cardului selectat și include fotografiile suplimentare disponibile pentru acel produs. Barele sistemului și randarea textului depind de platformă. [Referința Figma](https://www.figma.com/design/3HeBH74VC2MHhKwXGnqI2e/Laboratoare-2026?node-id=0-1)

## Verificare locală

```powershell
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

După compilare, APK-ul este în `build/app/outputs/flutter-apk/app-debug.apk`.

Testele folosesc răspunsuri V1 salvate în `test/fixtures` și un client HTTP simulat. La rularea aplicației, datele se descarcă din serviciul V1.
