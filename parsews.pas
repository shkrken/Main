unit parsews;
interface
uses ourtype, ourprocedures;


procedure parsewAtt(s1:string; a:integer; var rec_Att_true: Att; var err_true: boolean);
procedure parsewSotr(s:string; a:integer; var rec_sotr_true: Sotr; var err_true: boolean; TD: data);

procedure read_in1(f1:text; var f2:text; kol_att:byte; arr_Att_true: arr_Att; DZ, TD: data);
procedure read_in2(f3:text; var arr_att_true: arr_Att; var kol_att:byte);


implementation

//парсевка строк в файле in2
procedure parsewAtt(s1:string; a:integer; var rec_Att_true: Att; var err_true: boolean);
var
  i,q,j: integer;
  k: string;
  err, PA2:byte;
  
begin
  q:=0; //счетчик полей
  k:=''; //строка которая сохраняет поле
  s1:=' '+s1+' ';
  i:= 1;
  PA2:= 0;
  while (i <= length(s1)) and (q < 3)  do begin
    if s1[i]<>' ' 
        then k:=k+s1[i]
        else if k<>'' then begin 
          inc(q);
          case q of
            1:  begin              
                    check_fam_or_prof(k,err,j);
                    case err of
                      0: rec_Att_true.Prof := k;
                      1: begin
                              writeln('Ошибка в файле in2 в строке ', a, ' - ' , k, ' - длина профессии превышает допустимые 20 символов.');
                              q:=11;
                         end;
                      2: begin
                              writeln('Ошибка в файле in2 в строке ', a, ' - ' , k, ' - ошибка в первой букве профессии. Первая буква должна быть заглавной латинской.');
                              q:=11;
                         end;
                      3: begin
                              writeln('Ошибка в файле in2 в строке ', a, ' - ' , k, ' - в профессии запрещенный символ: ' + k[j] + ', номер символа: ' + j + '. Все буквы кроме первой должны быть строчными латинскими.');
                              q:=11;
                         end;
                    end;
                end;
            2: begin 
                   check_PA(k, err, PA2);
                   case err of
                     0: rec_Att_true.PA := PA2;
                     1: begin
                              writeln('Ошибка в файле in2 в строке ', a, ' - ' , k, ' - длина поля "Периодичность аттестации" должна быть 2 символа.');
                              q:=11;
                        end;
                     2: begin
                              writeln('Ошибка в файле in2 в строке ', a, ' - ' , k, ' - в поле "Периодичность аттестации" замечен недопустимый символ, используйте для ввода цифры.');
                              q:=11;
                        end;
                     3: begin
                              writeln('Ошибка в файле in2 в строке ', a, ' - ' , k, ' - в поле "Периодичность аттестации" встречено недопустимое значение. Используйте целые числа в диапазоне [12..36].');
                              q:=11;
                        end;
                   end;
             end;
         end; 
         k:='';
        end;
       i:=i+1; 
    end;
    if (q = 0) then begin
                          writeln('Ошибка в файле in2 в строке ', a, ' - пустая строка.');
                          err_true:=true;
                    end 
               else if (q > 0) and (q < 2) 
                        then begin
                                  writeln('Ошибка в файле in2 в строке ', a, ' - неполные данные.');
                                  err_true:=true;
                             end
                        else if (q > 2) and (q <> 11)
                                      then begin
                                                writeln('Ошибка в файле in2 в строке ', a, ' - лишние данные.');
                                                err_true:=true;
                                            end
                                      else if (q = 11) then err_true:=true;
end;


procedure parsewSotr(s:string; a:integer; var rec_sotr_true: Sotr; var err_true: boolean; TD: data);
var
  i,q: integer;
  k: string;
  err, flag:byte;
  j:integer; //для вывода символа
  data_sotr: data;
  numP: longint; //для записи номера паспорта
  
begin
  q:=0; //счетчик полей
  k:=''; //строка которая сохраняет поле
  s:=' '+s+' ';
  i:=1;
  
  while (i <= length(s)) and (q < 8)  do begin
    if s[i]<>' ' 
        then k:=k+s[i]
        else if k<>'' then begin 
          inc(q);
          case q of
            1:  begin  //поле фамилии              
                    check_fam_or_prof(k,err,j);
                    case err of
                      0: rec_sotr_true.Fam := k;
                      1: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - длина поля "Фамилия" не должна превышать 20 символов.');
                              q:=11;
                         end;
                      2: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - Ошибка в первой букве фамилии. Первая буква должна быть заглавной латинской.');
                              q:=11;
                         end;
                      3: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в фамилии запрещенный символ: ' + k[j] + ', номер символа: ' + j + '. Используйте для записи фамилии только прописные латинские буквы');
                              q:=11;
                         end;
                    end;
                end;
            2: begin //поле инициалов
                   check_inic(k, err);
                   case err of
                     0: rec_sotr_true.i := k;
                     1: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - длина поля "Инициалы" должна быть 4 символа.');
                              q:=11;
                        end;
                     2: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - ошибка в букве инициалов.  Инициалы должны быть записаны заглавными латинскими буквами');
                              q:=11;
                        end;
                     3: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Инициалы" замечен недопустимый символ. Инициалы должны быть записаны в формате [A.D.]');
                              q:=11;
                        end;
                   end;
             end;
            3: begin //поле Пола
                   check_pol(k, err);
                   case err of
                     0: rec_sotr_true.pol:=k;
                     1: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, '- длина поля "Пол" должна быть 1 символ.');
                              q:=11;
                        end;
                     2: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Пол" замечен недопустимый символ. Для записи пола используйте только заглавные латинские буквы (F или M)');
                              q:=11;
                        end;
                   end;
               end;
            4: begin //поле профессии          
                    check_fam_or_prof(k,err,j);
                    case err of
                      0: rec_sotr_true.Prof := k;
                      1: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - длина поля "Профессия" не должна превышать 20 символов.');
                              q:=11;
                         end;
                      2: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - ошибка в первой букве профессии. Первая буква должна быть заглавной латинской.');
                              q:=11;
                         end;
                      3: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в профессии запрещенный символ: ' + k[j] + ', номер символа: ' + j + '. Используйте для записи фамилии только прописные латинские буквы');
                              q:=11;
                         end;
                    end;
              end;
          5: begin //поле даты дня рождения
                   check_data(k, err, data_sotr.dd, data_sotr.mm, data_sotr.yyyy);
                   if ((data_sotr.yyyy < 1960) or (data_sotr.yyyy > 2000)) and (err = 0) then err:=31;
                   case err of
                     0:  rec_sotr_true.DR:=data_sotr;
                     1:  begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - длина поля "Дата рождения" должна быть 10 символов.');
                              q:=11;
                         end;
                     2:  begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Дата рождения" замечен(-ы) недопустимый(-ые) разделитель(-и) используйте в качестве разделителя(-ей) точки.');
                              q:=11;
                         end;
                     12: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Дата рождения"(день) замечен(-ы) недопустимый(-ые) символ(-ы) используйте для ввода цифры.');
                              q:=11;
                         end;
                     21: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле «Дата рождения» в значении месяц встречено недопустимое значение. Значение должно соответствовать (1..12).');
                              q:=11;
                         end;
                     22: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Дата рождения" (месяц) замечен(-ы) недопустимый(-ые) символ(-ы) используйте для ввода цифры.');
                              q:=11;
                         end;
                     31: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле «Дата рождения» в значении год встречено недопустимое значение. Значения должны соответствовать (1960...2000).');
                              q:=11;
                         end;
                     32: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Дата рождения" (год) замечен(-ы) недопустимый(-ые) символ(-ы) используйте для ввода цифры.');
                              q:=11;
                         end;
                     102:begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле «Дата рождения» в значении день встречено недопустимое значение. Для этого месяца ', data_sotr.dd, ' и этого года ', data_sotr.yyyy, ' значения должны соответствовать (1..29).');
                              q:=11;
                         end;
                     103:begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле «Дата рождения» в значении день встречено недопустимое значение. Для этого месяца ', data_sotr.dd, ' и этого года ', data_sotr.yyyy, ' значения должны соответствовать (1..28).');
                              q:=11;
                         end;
                     104:begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле «Дата рождения» в значении день встречено недопустимое значение. Для этого месяца ', data_sotr.dd, ' значения должны соответствовать (1..30).');
                              q:=11;
                         end;
                     105:begin 
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле «Дата рождения» в значении день встречено недопустимое значение. Для этого месяца ', data_sotr.dd, ' значения должны соответствовать (1..31).');
                              q:=11;
                         end;
                   end;
              end;
            6: begin //поле даты последней аттестации
                   check_data(k, err, data_sotr.dd, data_sotr.mm, data_sotr.yyyy);
                   if ((data_sotr.yyyy < 1982) or (data_sotr.yyyy > 2022)) and (err = 0) then err:=31;
                   case err of
                     0:  begin
                              check_old(data_sotr, rec_sotr_true.DR, err);
                              if (err = 0) 
                                  then begin
                                            flag:=2;
                                            check_s_TD(TD,data_sotr,err,flag); //текущая дата проверяется с датой заседания
                                            if (err = 0 )
                                                    then rec_sotr_true.DPA:=data_sotr
                                                    else begin
                                                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, '. в поле "Дата последней аттестации" замечено недопустимое значение. Дата последней аттестации не должна превышать Текущую дату.');
                                                              q:=11;
                                                         end;
                                      end              
                                  else begin
                                            writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, '. в поле "Дата последней аттестации" замечено недопустимое значение. Дата последней аттестации должна превышать дату рождения минимум на 18 лет.');
                                            q:=11;
                                       end;
                         end;
                     1:  begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - длина поля "Дата последней аттестации" должна быть 10 символов.');
                              q:=11;
                         end;
                     2:  begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Дата последней аттестации" замечен(-ы) недопустимый(-ые) разделитель(-и) используйте в качестве разделителя(-ей) точки.');
                              q:=11;
                         end;
                     12: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Дата последней аттестации"(день) замечен(-ы) недопустимый(-ые) символ(-ы) используйте для ввода цифры.');
                              q:=11;
                         end;
                     21: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Дата последней аттестации" в значении месяц встречено недопустимое значение. Значение должно соответствовать (1..12).');
                              q:=11;
                         end;
                     22: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Дата последней аттестации"(месяц) замечен(-ы) недопустимый(-ые) символ(-ы) используйте для ввода цифры.');
                              q:=11;
                         end;
                     31: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Дата последней аттестации" в значении год встречено недопустимое значение. Значения должны соответствовать (1982...2022).');
                              q:=11;
                         end;
                     32: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Дата последней аттестации"(год) замечен(-ы) недопустимый(-ые) символ(-ы) используйте для ввода цифры.');
                              q:=11;
                         end;
                     102:begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Дата последней аттестации" в значении день встречено недопустимое значение. Для этого месяца ', data_sotr.dd, ' и этого года ', data_sotr.yyyy, ' значения должны соответствовать (1..29).');
                              q:=11;
                         end;
                     103:begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Дата последней аттестации" в значении день встречено недопустимое значение. Для этого месяца ', data_sotr.dd, ' и этого года ', data_sotr.yyyy, ' значения должны соответствовать (1..28).');
                              q:=11;
                         end;
                     104:begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Дата последней аттестации" в значении день встречено недопустимое значение. Для этого месяца ', data_sotr.dd, ' значения должны соответствовать (1..30).');
                              q:=11;
                         end;
                     105:begin 
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Дата последней аттестации" в значении день встречено недопустимое значение. Для этого месяца ', data_sotr.dd, ' значения должны соответствовать (1..31).');
                              q:=11;
                         end;
                   end;
                   
              end;
           7: begin //поле номера паспорта
                    check_ID(k, err, numP);
                    case err of
                      0: rec_sotr_true.ID:=numP;
                      1: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - длина поля "Номер паспорта" должна быть 6 символов.');
                              q:=11;
                         end;
                      2: begin
                              writeln('Ошибка в файле in1 в строке ', a, ' - ' , k, ' - в поле "Номер паспорта" замечен(-ы) недопустимый(-ые) символ(-ы), используйте для ввода цифры.');
                              q:=11;
                         end;
                    end;
              end;
         end; 
         k:='';
        end;
       i:=i+1; 
    end;
    
    
    if (q = 0) then begin
                          writeln('Ошибка в файле in1 в строке ', a, ' - пустая строка.');
                          err_true:=true;
                    end 
               else if (q > 0) and (q < 7) 
                        then begin
                                  writeln('Ошибка в файле in1 в строке ', a, ' - неполные данные.');
                                  err_true:=true;
                             end
                        else if (q > 7) and (q <> 11)
                                      then begin
                                                writeln('Ошибка в файле in1 в строке ', a, ' - лишние данные.');
                                                err_true:=true;
                                            end
                                      else if (q = 11) then err_true:=true;
end;



  //работа с файлом профессий
procedure read_in2(f3:text; var arr_att_true: arr_Att; var kol_att:byte);
var a, flag, jj: byte;
    err_true:boolean;
    s1: string;
    rec_Att_true: Att;
begin
  while not eof(f3) and (a < n) do 
  begin
    err_true := false;
    readln(f3, s1);
    a := a + 1;
    parsewAtt(s1, a, rec_Att_true, err_true); //парсевка строки
    
    //подсчет верных строк и внесение в массив, проверка на уникальность профессии
    if not err_true 
        then begin 
                 flag:=0; //проверка на уникальность профессии
                 for jj:=1 to kol_att do 
                                if arr_att_true[jj].Prof = rec_att_true.Prof
                                      then begin 
                                                writeln('Ошибка в файле in2 в поле "Профессия" в строке ', a, ' - ', rec_att_true.Prof, ' - совпадает с "Профессия" в строке ');
                                                flag:=1;
                                      end;
                                if (flag<>1) 
                                            then begin
                                                      inc(kol_att);
                                                      arr_Att_true[kol_att] := rec_Att_true;
                                            end;
              end;           
  end;

  if not eof(f3) then writeln('in2 Кол-во строк больше ', N, ' строк');
end;

//работа с файлом сотрудников, только в том случае если есть верные строки в файле с профессиями
procedure read_in1(f1:text; var f2: text; kol_att:byte; arr_Att_true: arr_Att; DZ, TD: data);
var
  flag, flag2, jj, a, kol_Sotr, kol_SotrAtt: byte;
  rec_Sotr_true: Sotr;
  arr_Sotr_true: arr_Sotr;
  err_true: boolean;
  arr_SotrAtt_true: arr_SotrAtt;
  s: string;
begin
  a := 0;
  if (kol_att <> 0) //если в файле in2 нет верных строк, то файл in1 не будет проверяться
     then begin
            while not eof(f1) and (a < n) do 
            begin
              err_true := false;
              readln(f1, s);
              a := a + 1;
              parsewSotr(s, a, rec_sotr_true, err_true, TD);
    
              //подсчет верных строк и внесение в массив, проверка на уникальность номера паспорта
              if not err_true 
                  then begin
                            flag:=0; //проверка на уникальность номера напспорта
                            for jj:=1 to kol_sotr do 
                                      if arr_sotr_true[jj].ID = rec_sotr_true.ID
                                            then begin 
                                                    writeln('Ошибка в файле in1 в строке ', a, ' - ', rec_sotr_true.ID, ' - такой номер паспорта уже есть.');
                                                    flag:=1;
                                                 end;
                                      if (flag = 0) 
                                            then begin
                                                      flag2:=0; //проверка есть ли профессия сотрудника в справочнике (0 - нет такой профессии. 1 - есть такая профессия)
                                                      for jj:=1 to kol_att do
                                                                if arr_att_true[jj].Prof = rec_sotr_true.Prof
                                                                      then begin
                                                                              inc(kol_sotr);
                                                                              arr_sotr_true[kol_sotr] := rec_sotr_true;
                                                                              flag2:=1;
                                                                           end ;   
                                                     if flag2 = 0 
                                                          then writeln('Ошибка в файле in1 в строке ', a, ' - ', rec_sotr_true.prof, ' - такой профессии в файле in2 не найдено');
                                                 end;                 
                       end;
          end;
  
         if not eof(f1) then writeln('in1 Кол-во строк больше ', N, ' строк');
  //формирование списка сотрудников, которые не прошли аттестации до указанной даты
         if (kol_sotr <> 0) 
              then begin
                        resh(f2,kol_sotr,kol_att,arr_Sotr_true,arr_Att_true, kol_SotrAtt, arr_SotrAtt_true, DZ);   //решение задачи
                        if kol_SotrAtt = 0 
                              then writeln(f2, 'До указанной даты заседания ', DZ.dd, '.', DZ.mm, '.', DZ.yyyy,' нет сторудников, которые подлежат аттестации')
                              else begin
                                      sort(arr_SotrAtt_true, kol_SotrAtt);         //сортировка
                                      writeln(f2, 'До указанной даты заседания ', DZ.dd, '.', DZ.mm, '.', DZ.yyyy,' данные сотрудники не прошли аттестацию');
                                      printTrue(f2,kol_SotrAtt,arr_SotrAtt_true);  //вывод в файл 2 верных строк
                                      writeln('Программа завершила работу');
                                   end;
                   end
              else writeln('В файле in1 нет корректных строк');
        end
    else writeln('В файле in2 нет корректных строк');
end;


end.