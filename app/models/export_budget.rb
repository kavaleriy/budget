class ExportBudget
  include Mongoid::Document
  # has_one :calendar
  belongs_to :town

  validates :year,:title,:town, presence: true
  validates :year, numericality: { only_integer: true }

  # after_initialize :initial_content_template

  field :year, type: Integer
  field :title, type: String
  # field :template, type: String
  # field :town_id, type: String
  # field :header, type: String
  # field :footer, type: String
  field :content, type: String

  def initial_content_template
    header_style = "style='height: 100px;
      line-height: 100px;
      background: blue;
      color: white;
      font-size: 35px;
      vertical-align: middle;
      text-align: center;'"

    text_style = "style='font-size: 22px;'"

    pre_header_style = "style='font-size:26px;
       text-align:center;
        color:#216BA1;'"

    img_input = "<img style='margin-left:25%' src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAUMAAACUCAYAAAAJf0skAAAanklEQVR4Xu3dB7clRRWG4caEiooZTIComBFzBn/6
oGIAAXMAMeccwQDienqxx6Lt0+few5xTdYev15o1M/d2d+36quqtXdXde19z6dKlJ6ccUSAKRIFnuQLXBIbn6wFPPvnk5M9znvOc812Ys4dX4D//+c90zTXX
zH96HKcoP/13d8sGhufs9b/73e+m733ve9MnP/nJc16Z00dX4Ctf+cr0ute9bnrDG97QxdRTlJ/+Gxhudu577713euyxx6ZPfOIT0/Of//ynnfub3/xm+va3
vz3dfPPN05vf/Obp3//+9/SPf/xjeulLX9plwKTQ4ynwt7/9bXrBC14w/+lxnKL86r///Oc/px/+8IfThz/84Xlyv/baa6dbbrmlR7WHKTOe4TRNYKiT6AxL
r+Ab3/jG9Oc//3n+ORjmiAJXgwJg+Pe//3165StfOf31r3+dt32uu+66q6FqB9chMHwKhi95yUtmj+8DH/jAZTH/9a9/TV/+8penl7/85ZPfg+FymfH73/9+
+sEPfjB7li9+8Yunt771rfP5f/jDH6Zvfetb06c//enL93vggQem1772tdMb3/jG+Wd//OMf59lZp3zuc587vf71r5890F17Vu759a9/fT7X8cQTT0wf+tCH
Ztscy9/bg9LZ3/ve986//9GPfjT98pe/nK9Thgngne9853TDDTc8rQO57rOf/ezlnynvFa94xXTbbbdd9pp+8pOfTD//+c+nxx9/fLr++uvn39HP5FG2GWDK
efWrXz2X86tf/WpynfN4X3QoLWjodw7XvPCFL5y1uPHGG+cyPv/5z89ejAH7i1/8Yv7z/ve/f/rc5z43feQjH5m1dzz44INzvfxseZQ+9XOrAPe/9dZb5zLb
ZSqd6OVe1a50+eY3vzmvIJ73vOddrucXvvCF6V3vete8Wnj44YenP/3pT5NzSxd1qUM9f/rTn17ec9YWb3nLW6Y3velNTyvfBOxejz766KyV39dEvaXjvn63
7L/33HPP9Pa3v31uo2f7ERg+BUMDz3IBXGpg/exnP5s7tkH9ohe96P9gCID33Xff3Jle9apXTb/+9a9nMH7sYx+bZ9stGLrW4AMRgNTpgQ5wDdC1AwAM0g9+
8IMz0ICghaHfAxRoONgCtGAI2gYy2NcS/0tf+tJc3i4YKse5vAiQYRfv2daBgeq+dPn+978/TwbtRAIQb3vb26bXvOY1sy3qxwN/z3veMwP6L3/5y/S1r31t
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'/>"

    input_place_style = "style='font-size: 14px;
      background: gray;
      opacity: 0.5;
      width: 50%;
      height: 150px;
      margin-left: 25%;
      text-align: center;'"

    document_text = "<div " + header_style + " >Ключові документи</div>

<div " + text_style +">для детального дослідження бюджету м. Одеса
Натисніть на назву документа, щоб перейти на офіційну сторінку органу
влади, де він розміщений
Бюджет м. Одеси на 2013 рік
Звіт про виконання бюджету м. Одеси на 2012 рік
Джерела фактично отриманих доходів в 2012 р., напрямки та статті витрат, порівняння з
запланованими доходами і видатками.
Пояснювальна записка про виконання бюджету м. Одеси на
2012 рік
Рівень ключових бюджетних показників (напр., рівня виконання бюджету, обсягу власних
доходів, обсягу надходжень до бюджету розвитку) у порівнянні із попереднім роком,
заборгованість міського бюджету, структуру окремих статей та іншу інформацію.
Генеральний план м. Одеси
Плани щодо використання території м. Одеси на найближчі роки.
Стратегія економічного та соціального розвитку м. Одеси до 2022 р.
Довгострокові цільові показники розвитку міста, досягнення яких заплановано до 2022 року;
Програма соціально-економічного розвитку м. Одеси на 2013 р.
Запланований рівень основних соціально-економічних показників (напр., середньомісячної
заробітна плата, площі введеного в експлуатацію житла, кількість зареєстрованих безробітних)
станом на кінець року.
Програма комплексного соціально-економічного розвитку
м. Одеси на 2005-2015 роки
Програма запланованих заходів у м. Одесі до 2015 року, із зазначенням запланованого обсягу
їхнього фінансування в тому числі з державного та обласного бюджетів.
Міські програми м. Одеси
В міських програмах визначено перелік заходів в конкретних сферах життя міста на найближчі
роки та очікувані результати від їхньої реалізації.
Регламент Одеської міської ради VI скликання
Інформація про порядок затвердження та виконання бюджету м. Одеса.</div>"

    info_text = "Джерела інформації
1. Бюджетний кодекс України.
2. http://www.odessa.ua – офіційний сайт міста Одеси.
3. http://www.od.ukrstat.gov.ua – Головне управління статистики в
Одескій області (офіційний веб-сайт).
4. Звіт про виконання бюджету м. Одеси на 2012 рік.
5. Звіт про виконання бюджету м. Одеси на 2011 рік.
6. Звіт про виконання бюджету м. Одеси на 2010 рік.
7. Пояснювальна записка про виконання бюджету м. Одеси на 2012 р.
8. Аналитическая информация о результатах деятельности системы
образования города Одессы за 2011 г. и 9 месяцев 2012 г.
9. Відповіді Одеської міської ради на інформаційні запити.
10. Лондар С. Л., Тимошенко О. В. Фінанси. Навчальний посібник.– Ві-
нниця: Нова Книга, 2009 – 384 с.
11. Ганущак Ю. І. Місцеві бюджети.– К. : Легальний статус, 2011.– 48 с.
12. Залучення громадян до діяльності органів місцевого самовряду-
вання: Навч. посіб./ І. Бураковський, В. Зайчикова, С. Максименко, І. Пара-
сюк. – За ред. І. Бураковського. – К. : УНІСЕРВ, 2004
Громадський бюджет підготувала експертна група
Центру Політичних Студій та Аналітики у складі
Володимира ТАРНАЯ, Павла МИРОНОВА та Віктора ТАРАНА.
Візуальне оформлення Вадима МІСЬКОГО."

# /////////////////////////////////////////////////
    self.content = "
<div " + header_style + " >— Що таке громадський бюджет?</div>

<div " + text_style + " >Громадський бюджет – це зрозуміла форма презентації осно-
вних бюджетних документів та результатів їх впровадження. Він
покликаний в доступній формі та доступною мовою дати громадянам розуміння ключових аспектів формування,
 результатів виконання та контролю за виконанням міського бюджету.
 Громадський бюджет надає короткий екскурс до ключових документів
міста та головних результатів його функціонування з точки зору
корисності їх для пересічного громадянина.
 Показники функціонування міста не обов’язково є безпосереднім результатом діяль-
ності міськради чи її виконавчих органів, проте істотно впливають на життя громадян.
Громадський бюджет сприяє підвищенню прозорості та
доступності основної бюджетної інформації, результатів діяльності
органів влади на місцях, коли будь-якому користувачеві стає зрозуміло,
 яким чином міська влада здійснює акумулювання, розподіл і використання коштів міського бюджету.
Для зручності користування громадський бюджет містить
гіперпосилання на ключові документи для детального
дослідження бюджету міста та департаменти і управління міської
ради які відають основними галузями на які спрямовані кошти
міськради. Ми переконані, що платники податків повинні знати,
 яким чином використовуються їхні кошти, та знати про свої
можливості впливати на цей процес їх використання.
Тому складовою частиною громадського бюджету є бюджетний календар
з зазначенням інструментів участі громадськості в бюджетному
процесі міста.</div>

<div " + header_style + ">Бюджет міста: просто про складне</div>
<div " + text_style + ">Бюджет відображає план
отримання доходів та їх використання для досягнення поставлених цілей.
 За принципом бюджетої рівноваги доходи та
видатки бюджету повинні бути збалансованими.
Фінуправління можуть формувати бюджетну інформацію в
різних розрізах в залежності від
потреби користувачів інформації.
Найчастіше інформацію про
видатки відображають за функціями які покладені на міську владу:<br>

" + img_input + "

<div " + text_style + ">Дізнатися звідки беруться гроші в бюджеті міста та куди вони
витрачаються Ви можете на наступній сторінці.</div>

<div " + header_style + " >— Куди йдуть мої гроші?</div>
<div " + text_style + " > Перегляд кошторису </div>

" + img_input + "



<div " + header_style + ">— Скільки витрачають на мене?</div>

<div " + text_style + " >Знайдіть послугу, якою користуєтесь, і перегляньте скільки коштів з
міського бюджету було витрачено у 2012 році в середньому
на одного отримувача</div>

<div " + header_style + ">Показники діяльності міста</div>
<div " + pre_header_style + ">та їх динаміка у 2010, 2011 та 2012 роках</div>
<div " + text_style + " > Тут зібрані ключові показники діяльності міста</div>

" + img_input + "
<div " + header_style + ">— Як впливати на бюджет міста?</div>
<div " + pre_header_style + " >Календар громадської участі у бюджетному процесі</div>
" + img_input
  end
end
