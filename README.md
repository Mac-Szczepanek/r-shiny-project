Kod R tworzy **interaktywną aplikację internetową w Shiny**, która wizualizuje dane sprzedażowe z arkusza `sample_-_superstore.xls`. Jej celem jest analiza i prognozowanie zysków w podziale na kategorie produktów, na podstawie danych historycznych do połowy 2017 roku.

### 📊 **Opis funkcjonalny aplikacji**

Aplikacja zawiera:

#### 🔧 **Panel boczny (kontrolny):**

* **Slider i kalendarz** do wyboru zakresu dat (zsynchronizowane).
* **RadioButton** do wyboru rodzaju prognozy: `mean_profit` (średnia) lub `median_profit` (mediana).
* **Pole liczbowego wejścia** do ustawienia *"hojności prognozy"* – % wzrostu zysku prognozowanego.
* **Przycisk "Reset"** do przywrócenia domyślnych ustawień.

#### 📈 **Główne wykresy:**

1. **Bar chart 1** – średnia liczba sprzedanych sztuk (`Quantity`) wg kategorii (słupkowy).
2. **Bar chart 2** – średni zysk (`Profit`) wg kategorii (słupkowy).
3. **Stacked bar 1** – zsumowane ilości (średnie) na wykresie skumulowanym.
4. **Stacked bar 2** – zsumowane zyski (średnie) na wykresie skumulowanym.
5. **Predykcja (predbar)** – wykres pokazujący zyski historyczne oraz prognozowane w 2017 roku na podstawie wcześniej wybranego typu prognozy.

### 🧮 **Dane i przetwarzanie**

Dane wczytywane są z pliku Excela `sample_-_superstore.xls`, a następnie:

* Ograniczane do dat przed 1 czerwca 2017.
* Grupowane według **roku i kategorii** w celu obliczenia zysków (`Profit`).
* Obliczana jest średnia i mediana zysków wg kategorii.
* Tworzona jest **prognoza dla 2017** z użyciem średniej lub mediany z poprzednich lat, modyfikowanej o wybrany procent hojności (`generosity`).

### 🎯 **Cel i zastosowanie**

Aplikacja rozwiązuje problem analizy wyników sprzedaży w czasie i prognozowania przyszłych wyników z wykorzystaniem prostych statystyk. Może być stosowana m.in. do:

* **Podejmowania decyzji biznesowych**: Które kategorie przynoszą największy zysk lub sprzedaż?
* **Oceny sezonowości i trendów**.
* **Testowania różnych scenariuszy** przyszłych wyników w zależności od polityki cenowej lub marketingowej (dzięki parametrowi "generosity").

### 🛠️ Technologie:

* **R (Shiny)** – do tworzenia interfejsu.
* **Tidyverse (dplyr, ggplot2, stringr)** – do transformacji danych i wizualizacji.
* **readxl** – do odczytu danych z Excela.
* **lubridate** – do manipulacji datami (choć nie jawnie załadowana w kodzie, jest używana przez `ymd()`).
