clear all;
close all;

load('HDFS_MUSE.mat','cube');
load('raie_lya.mat','raie_lya');

% Création du vecteur de longueurs d'onde
pas = 0.125; % Pas de 0.125 nm
lambda_lya = 0:pas:(10-1)*pas; % 10 points, de 0 à 10*pas avec un pas de 0.125 nm

% Tracé de la raie Lyα
plot(lambda_lya, raie_lya);
xlabel('Longueur d''onde (nm)');
ylabel('Intensité');
title('Spectre de la raie Lyα');

dims = size(cube);

lambda_start = 475;   % Début du spectre en nm
lambda_end = 930;     % Fin du spectre en nm
spectral_res = 0.125; % Résolution spectrale en nm

% Calcul du nombre total de points dans le spectre
num_points = 1 + (lambda_end - lambda_start) / spectral_res;

% Création du vecteur lambda
lambda = linspace(lambda_start, lambda_end, num_points);


%% AFFICHAGE DE DEUX SPECTRES


% Récupération du spectre du pixel (2, 2)
spectre_2_2 = squeeze(cube(2, 2, :));

% Création de la première figure pour le pixel (2, 2)
figure; % Ouvre une nouvelle fenêtre graphique
plot(lambda, spectre_2_2);
xlabel('Longueur d''onde (nm)');
ylabel('Intensité');
title('Spectre du pixel (2, 2)');

% Récupération du spectre du pixel (10, 10)
spectre_10_10 = squeeze(cube(10, 10, :));

% Création de la deuxième figure pour le pixel (10, 10)
figure; % Ouvre une autre nouvelle fenêtre graphique
plot(lambda, spectre_10_10);
xlabel('Longueur d''onde (nm)');
ylabel('Intensité');
title('Spectre du pixel (10, 10)');



%% CALCUL DES AUTOCORRELATION/INTERCORRELATION


% Récupération des spectres
spectre_2_2 = squeeze(cube(2, 2, :));
spectre_10_10 = squeeze(cube(10, 10, :));

% Calcul de l'autocorrélation pour le pixel (2, 2)
[acor_2_2, lags] = xcorr(spectre_2_2 - mean(spectre_2_2), 'coeff');

% Calcul de l'autocorrélation pour le pixel (10, 10)
[acor_10_10, lags_10_10] = xcorr(spectre_10_10 - mean(spectre_10_10), 'coeff');

% Calcul de l'intercorrélation entre les deux spectres
[xc, lags_xc] = xcorr(spectre_2_2 - mean(spectre_2_2), spectre_10_10 - mean(spectre_10_10), 'coeff');

% Création d'une figure pour les trois sous-graphiques
figure;

% Sous-graphique 1 : Autocorrélation du spectre du pixel (2, 2)
subplot(3, 1, 1);
stem(lags, acor_2_2);
xlabel('Décalage');
ylabel('Autocorrélation');
title('Autocorrélation du spectre du pixel (2, 2)');

% Sous-graphique 2 : Autocorrélation du spectre du pixel (10, 10)
subplot(3, 1, 2);
stem(lags_10_10, acor_10_10);
xlabel('Décalage');
ylabel('Autocorrélation');
title('Autocorrélation du spectre du pixel (10, 10)');

% Sous-graphique 3 : Intercorrélation entre les spectres
subplot(3, 1, 3);
stem(lags_xc, xc);
xlabel('Décalage');
ylabel('Intercorrélation');
title('Intercorrélation entre les spectres des pixels (2, 2) et (10, 10)');




%% CALCUL DE LAMBDA_0

% Récupération du spectre du pixel (9, 8)
spectre_9_8 = squeeze(cube(9, 8, :));

% Création du filtre adapté (version inversée de la raie Lyα)
filtre_adapte = fliplr(raie_lya);

% Application du filtre adapté
sortie_filtre = filter(filtre_adapte, 1, spectre_9_8);

% Trouver la position maximale dans la sortie du filtre
[sortie_max, pos_max] = max(sortie_filtre);

% Longueur d'onde correspondante à la position maximale
lambda0 = lambda(pos_max);

% Affichage de la sortie du filtre adapté
figure;
plot(lambda, sortie_filtre);
hold on; % Permet de superposer le point maximum
plot(lambda(pos_max), sortie_max, 'r*', 'MarkerSize', 10); % Point maximum
hold off;

% Ajout des étiquettes et du titre
xlabel('Longueur d''onde (nm)');
ylabel('Sortie du filtre adapté');
title(['Sortie du filtre adapté pour le pixel (9, 8), \lambda_0 = ' num2str(lambda0) ' nm']);



%% CALCUL AVEC SOUS CUBE

% Extraction du sous-cube
sous_cube = cube(7:10, 7:9, :);

% Calcul du spectre moyen
spectre_moyen = mean(mean(sous_cube, 1), 2);
spectre_moyen = squeeze(spectre_moyen);

% Création du filtre adapté (version inversée de la raie Lyα)
filtre_adapte = fliplr(raie_lya);

% Application du filtre adapté au spectre moyen
sortie_filtre = filter(filtre_adapte, 1, spectre_moyen);

% Trouver la position maximale dans la sortie du filtre
[~, pos_max] = max(sortie_filtre);

% Longueur d'onde correspondante à la position maximale
lambda0 = lambda(pos_max);

% Affichage de la sortie du filtre adapté
figure;
plot(lambda, sortie_filtre);
hold on;
plot(lambda(pos_max), sortie_filtre(pos_max), 'r*', 'MarkerSize', 10); % Point maximum
hold off;

% Ajout des étiquettes et du titre
xlabel('Longueur d''onde (nm)');
ylabel('Sortie du filtre adapté');
title(['Sortie du filtre adapté pour le spectre moyen, \lambda_0 = ' num2str(lambda0) ' nm']);


%% CALCUL RSB

% Application du filtre adapté au spectre individuel (9, 8)
sortie_filtre_individuel = filter(filtre_adapte, 1, spectre_9_8);
signal_max_individuel = max(sortie_filtre_individuel);
bruit_var_individuel = var(sortie_filtre_individuel - signal_max_individuel);
RSB_individuel = signal_max_individuel^2 / bruit_var_individuel;

% Application du filtre adapté au spectre moyen
sortie_filtre_moyen = filter(filtre_adapte, 1, spectre_moyen);
signal_max_moyen = max(sortie_filtre_moyen);
bruit_var_moyen = var(sortie_filtre_moyen - signal_max_moyen);
RSB_moyen = signal_max_moyen^2 / bruit_var_moyen;

% Comparaison des RSB
amelioration_RSB = RSB_moyen / RSB_individuel


%% DETECTION DE LA GALAXIE

% Paramètres initiaux
filtre_adapte = fliplr(raie_lya);

% Matrice pour stocker les valeurs maximales
max_vals = zeros(size(cube, 1), size(cube, 2));

% Balayage du cube
for i = 1:size(cube, 1)
    for j = 1:size(cube, 2)
        % Extrait le spectre du pixel courant
        spectre = squeeze(cube(i, j, :));

        % Applique le filtre adapté
        sortie_filtre = filter(filtre_adapte, 1, spectre);

        % Stocke la valeur maximale
        max_vals(i, j) = max(sortie_filtre);
    end
end

% Affichage des valeurs maximales
figure;
imagesc(max_vals);
colorbar;
title('Réponse maximale du filtre adapté sur chaque pixel');
xlabel('Position X');
ylabel('Position Y');


%% BALAYAGE AVEC FILTRE MOYENNEUR ET ZERO PADDING 

% Paramètres initiaux
filtre_adapte = fliplr(raie_lya);
taille_sous_region = [3, 3]; % Taille des sous-régions (ex. 3x3 pixels)

% Padding size
padding_size = floor(taille_sous_region / 2);

% Création du cube avec zero padding
padded_cube = padarray(cube, padding_size, 0, 'both');

% Matrices pour stocker les valeurs maximales et les longueurs d'onde correspondantes
max_vals = zeros(size(cube, 1), size(cube, 2));
lambda_max_vals = zeros(size(cube, 1), size(cube, 2)); % Pour les longueurs d'onde

% Balayage du cube avec des sous-régions
for i = 1:size(cube, 1)
    for j = 1:size(cube, 2)
        % Indices pour le sous-cube avec padding
        padded_i = i : (i + taille_sous_region(1) - 1);
        padded_j = j : (j + taille_sous_region(2) - 1);

        % Extraction du sous-cube avec padding
        sous_cube = padded_cube(padded_i, padded_j, :);

        % Calcul du spectre moyen de la sous-région
        spectre_moyen = mean(mean(sous_cube, 1), 2);
        spectre_moyen = squeeze(spectre_moyen);

        % Application du filtre adapté au spectre moyen
        sortie_filtre = filter(filtre_adapte, 1, spectre_moyen);

        % Enregistrement de la valeur maximale et de sa position
        [max_val, pos_max] = max(sortie_filtre);
        max_vals(i, j) = max_val;

        % Conversion de la position en longueur d'onde
        lambda_max_vals(i, j) = lambda(pos_max);
    end
end

% Affichage des valeurs maximales
figure;
imagesc(max_vals);
colorbar;
title('Réponse maximale du filtre adapté après moyennage avec zero padding');
xlabel('Position X');
ylabel('Position Y');
colormap('jet'); % Utiliser une colormap pour mieux visualiser les différences

% Affichage des longueurs d'onde correspondantes aux valeurs maximales
figure;
imagesc(lambda_max_vals);
colorbar;
title('Longueur d''onde correspondant à la valeur maximale après moyennage avec zero padding');
xlabel('Position X');
ylabel('Position Y');
colormap('hot'); % Colormap pour les longueurs d'onde
