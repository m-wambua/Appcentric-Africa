for setting up the back end
git clone Appcentric-Africa
cd back-end

composer install
php artisan migrate --seed

php artisan serve



for the front end
cd appcentricafrica

flutter pub get

flutter run
