echo "Цей скрипт використовує різні можливості програмування на Bash."

cwd='/tmp/bekuzarov-pz4'

if [ -d $cwd ]; then
    echo "Директорія $cwd існує, її буде очищено."
    rm -rf "$cwd/*"
else
    echo "Директорії $cwd ще не існує, її буде створено."
    mkdir -p "$cwd"
    if [ $? -ne 0 ]; then
        echo "На ДУЖЕПРЕВЕЛИКИЙЖАЛЬ, директорію $cwd створити не вдалося, тому я розбіжавшись, пригну зі скали..."
        exit 1;
    fi
fi

cd "$cwd"

{
    echo "А зараз ми виведемо щось на екран";
    echo "За допомогою списку команд";
    echo "{}";
}

async_sleep() {
    sleep 5;
    echo "Я прокинувся через 5 секунд!"
}

echo "Запускаємо асинхронну команду на 5 секунд..."

async_sleep &
async_pid=$!
echo "Асинхронна команда має PID=$async_pid"
# wait $async_pid
echo "Зараз ми виведемо що-небудь за домопогою оператору <<"


cat << EOF
    що небудь
EOF

echo "Позапускаємо програми через && та ||"

echo "true || false && echo 'УРА!'"
true || false && echo 'УРА!'

echo "true && false && echo 'УРА!'"
true && false && echo 'УРА!'

echo "true || false || echo 'УРА!'"
true || false || echo 'УРА!'

echo "true || false || echo 'УРА!'"
false || true && echo 'УРА!'

echo "Досить гратися. Зробимо щось із циклом."

i=0
while true && true && echo "Перевіряємо умову циклу..."; do
    echo "Мама я в циклі!!!"
    (( i += 1))

    if [ $i -eq 3 ]; then
        echo "HALT!!!"
        break
    fi
done

for PERSON in Тато Мамо Коханка; do
    echo "У нас в родині є $PERSON";
done

echo "Нехай в нас є змінна A=145"
A=145
echo "Запустимо щось з під-оболонки:"
({ echo "Ми в підоболонці"; echo "A було $A"; A=5; echo "A стало $A"; })
echo "Повертаємося до оригінальної оболонки:"
echo "А не змінилося, все ще $A"

echo "Дочекаємося нашого асинхронного процесу..."
wait $async_pid

echo "Наш асинхронний процес завершився з кодом $! - це успіх!"