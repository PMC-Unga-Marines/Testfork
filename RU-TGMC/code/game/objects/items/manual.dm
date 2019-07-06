/obj/item/book/manual/tank_manual

	name = "USCM Armored vehicles Guide For Dummies. Updated"
	icon_state = "bookTank"
	author = "USCM Tech Division"
	title = "USCM Armored Vehicles Manual. Revision 2"

	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				body {font-size: 13px; font-family: Verdana;}
				</style>
				</head>
				<body>

				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#Foreword">Author's Foreword/Предисловие</a></li>
					<li><a href="#Part_1">Part 1: The Tank</a></li>
					<li><a href="#General">General Information</a></li>
					<li><a href="#Primary">Primary Weaponry</a></li>
					<li><a href="#Secondary">Secondary Weaponry</a></li>
					<li><a href="#Support">Support Modules</a></li>
					<li><a href="#Armor">Tank Armor</a></li>
					<li><a href="#Treads">Treads</a></li>
					<li><a href="#Updates">New Features</a></li>
					<li><a href="#Tips_1">Tips For Rookies</a></li>
					<li><a href="#Part_2">Part 2: The APC</a></li>
					<li><a href="#Part_1_ru">Часть ПерваЯ: Танк</a></li>
					<li><a href="#General_ru">ОбщаЯ ИнформациЯ</a></li>
					<li><a href="#Primary_ru">Основные Оружейные Модули</a></li>
					<li><a href="#Secondary_ru">Дополнительные Оружейные Модули</a></li>
					<li><a href="#Support_ru">Вспомогательные Модули</a></li>
					<li><a href="#Armor_ru">ТанковаЯ БронЯ</a></li>
					<li><a href="#Treads_ru">Траки</a></li>
					<li><a href="#Updates_ru">Новые Особенности</a></li>
					<li><a href="#Tips_1_ru">Советы ДлЯ Новичков</a></li>
					<li><a href="#Part_2_ru">Часть 2: БТР</a></li>
				</ol><br>

				<h1><a name="Foreword"><U><B>HOW TO BE A GOOD ARMOR CREW</B></U></a></h1><BR>
				<I>Or: What All These "M"'s mean?</I><BR><BR>

				This Technical Manual supposed to help rookie Armor Crew members (AC from here) to get the basics of M46
				"Stingray" Modular Multipurpose Tank and M580 Armored Personnel Carrier. In USCM Armor School you were trained on training M29 "Junior"
				with standard equipment loadouts that instructors chose for you. That's not how it works during actual sector patrolling
				and combat operations. You must decide what vehicle you will choose, what will you install on your it before each operation, considering
				mission type, intel on possible hostiles and environment conditions in AO. This manual will help you to make a choice
				of equipment for your first mission (hopefully, not last, we believe in you).<BR><BR>

				Это Техническое Руководство послужит помощником новеньким танкистам (далее - AС) в постигании азов работы на
				М46 "Скат" Модульном Многоцелевом Танке и М580 Бронетранспортере. Во времЯ учебы в Бронетанковом Училище USCM вы тренировались на
				учебном М29 "Junior" со стандартными наборами оборудованиЯ, которые определЯлись вашими инструкторами. В реальных
				условиЯх ведениЯ патрульной службы в секторе и боевых операциЯх все обстоит несколько иначе. Именно вы должны выбирать
				какую технику вы будете использовать, оборудование длЯ установки на выбранную технику перед каждой операцией, учитываЯ тип операции, данные о возможном противнике
				и условиЯх окружающей среды в зоне операции. Это техническое руководство поможет вам с выбором оборудованиЯ длЯ вашей
				первой миссии (надеемсЯ, не последней).<BR><BR>

				<h1><a name="Part_1"><U><B>Part 1: The Tank</B></U></a></h1><BR>
				<I>Metal beast.</I><BR><BR>

				<h1><a name="General"><B>General Information</B></a></h1>
				<I>Important things you need to know.</I><BR><BR>
				<li>First of all, you need to know that M46 has MT45 "Roadhog" engine. It's powerful enough to get tank itself to desired location quite quickly
				(provided you installed treads). That's about it. As soon as you start installing modules on hardpoints, you will soon notice decrease in speed.
				Which means, you will have to choose between speed, armor and firepower. Depending on tank weight, you can loosely assign tank to Light, Medium or
				Heavy class. Heavy class would be slowest, obviously, while Light class tank is still quite fast going. However, weight of the tank affects not only speed,
				it also affects accuracy of installed weapons a small bit. Heavy class tank, due it's weight, will provide better stability while shooting, which, theoretically,
				will result in slightly more accurate shooting. So you better keep that in mind too, when you make your choice. To get rid of big numbers, we introduce to you
				"Relative Weight" system. Each module has "Relative Weight" (RW) which you will use to calculate your tank's loadout weight. Tank classes division goes: up to 10 RW
				is Light class, 11 RW to 15 RW is Medium class and 16+ RW is Heavy class.</li>
				<li>M46 has improved weapon loading system, which lacks constructional defect of previous versions that led to inability to unload last magazine. Also new system
				will automatically unload all loaded in it magazines, including the one in the weapon, while you will uninstall weaponry.</li>
				<li>"Stingray" also has inbuilt M75 Smoke Deploy System. Upon activation it shoots two smoke grenades in front of tank, effectively covering tank from enemy sight in
				direction tank looks toward to. Both TCs have access to M75.</li>
				<li>Engineers managed to slightly increase interior space, which allowed to swap seats even with both TCs in tank.</li>
				<li>Also they installed sensors and new interface, that shows tank status on demand, including: all modules overall integrity in per cents, ammo counts in primary and
				secondary weapons, backup magazines and amount of M75 uses left.</li>
				<li>Auxiliary top hatch was added to tank, allowing to enter vehicle even if back hatchet is blocked.</li>
				<li>Special camera was mounted on the tank, allowing Command Staff in CIC to actually view the tank (Armored Vehicle in cameras list).</li>
				<li>External Megaphone was installed and tested. However, you yourself won't hear what you are saying in it.</li>
				<li>Remember that anyone who has squad engineer level of training is capable of, uninstalling, field repairing and installing back your broken treads.</li>
				<li>All modules can be fixed in special Module Repair Station in the Garage next to Tank Vendor.</li>

				<h1><a name="Primary"><B>Primary Weaponry</B></a></h1>
				<li><I>M21 Autocannon.</I> 1RW. A primary light autocannon for tank. Designed for light scout tank. Fire rate was reduced with adding IFF support. Supports two ammo types: AP - 30mm Armor-Piercing shell; SCR - Special Concussion Round for suppressing enemy infantry.</li>
				<li><I>M5 LTB Cannon.</I> 2RW. A primary 86mm cannon for tank. Supports three shell types: AP - Armor-Piercing; HE - High-Explosive shell used against enemy infantry; HEAT - High-Explosive Anti-Tank ammunition, for dealing with targets behind armor or fortifications.</li>
				<li><I>M74 LTAA-AP Minigun.</I> 3RW. It's a minigun, what is not clear? Just go pew-pew-pew.</li>

				<h1><a name="Secondary"><B>Secondary Weaponry</B></a></h1>
				<li><I>M56 "Cupola".</I> 2RW. Refitted M56 has higher accuracy and rate of fire. Compatible with IFF system.</li>
				<li><I>M8-3 TOW Launcher.</I> 2RW. Shoots powerful AP rockets. Deals heavy damage, but only on direct hits.</li>
				<li><I>M7 "Dragon" Flamethrower Unit.</I> 2RW. Don't let it fool you, it's not your ordinary flamer, this thing literally shoots fireballs. No kidding.</li>
				<li><I>M92 Grenade Launcher.</I> 2RW. Shoots HEDP grenades further than you see. No, seriously, that's how it works.</li><BR><BR>

				<h1><a name="Support"><B>Support Modules</B></a></h1>
				<li><I>M40 Integrated Weapons Sensor Array.</I> 1RW. Improves the accuracy and fire rate of all installed weapons. Actually more useful than you may think.</li>
				<li><I>M103 Overdrive Enhancer.</I> 1RW. Improvement for your engine. Increases the movement and turn speed of the vehicle it's attached to.</li>
				<li><I>M6 Artillery Module.</I> 1RW. A bunch of enhanced optics and targeting computers. Greatly increases range of view of a gunner. Also adds structures visibility even in complete darkness.</li>

				<h1><a name="Armor"><B>Tank Armor</B></a></h1>
				<li><I>M65-B.</I> 7RW. Standard tank armor. Middle ground in everything, from damage resistance to weight.</li>
				<li><I>M70 "Caustic".</I> 5RW. Special set of tank armor. Purpose: reduce vehicle parts degradation in hostile surroundings on planets with unstable and highly corrosive atmosphere.</li>
				<li><I>M66-LC.</I> 4RW. Light armor, designed for recon type of tank loadouts. Offers less protection in exchange for better maneuverability. After initial tests resistance to blunt damage was increased due to drivers driving into walls.</li>
				<li><I>M90 "Paladin".</I> 10RW. Heavy armor for heavy tank. Converts your tank into what an essentially is a slowly moving bunker. High resistance to almost all types of damage.</li>
				<li><I>M37 "Snowplow".</I> 3RW. Special set of tank armor, equipped with multipurpose front \"snowplow\". Designed to remove snow and demine minefields. As a result armor has high explosion damage resistance in front, while offering low protection from other types of damage.</li>

				<h1><a name="Treads"><B>Treads</B></a></h1>
				<li><I>M2 Tank Treads.</I> 1RW. Standard tank treads. Suprisingly, greatly improves vehicle moving speed.</li>
				<li><I>M2-R Tank Treads.</I> 3RW. Heavily reinforced tank treads. Three times heavier but can endure more damage. Has special protective layer akin to M70 armor.</li><BR><BR>

				<h1><a name="Updates"><B>New Features</B></a></h1>
				<li>Engineers updated operating systems of the M46 with more sophisticated software. Introducing: User Interface. By hitting new "Activate UI" button, UI window will startup.</li>
				<li>Attention! System is yet to be fully tested, please, report any problems during operation to USCM Tech Division.</li>

				<h1><a name="Tips_1"><B>Tips For Rookies</B></a></h1>
				<h3><B>Tips for both:</B></a></h3>
				<li><B>1. Anger management.</B> There will always be at least one marine yelling at you for no reason. Your other AC will sooner or later make serious mistake. Take it easy, tank needs cold head to be effective and not harmful for allies.</li>
				<li><B>2. Team work is essential.</B> Both between you and your other AC and between tank and marine squads. Tank and infantry are supposed to cover each other's weaknesses. Keep that in mind when you will drive somewhere alone.</li>
				<li><B>3. Panic is deadly.</B> You panic - you are done. Simple as that.</li>
				<li><B>4. At high cost.</B> If it's clear to you that you are not getting out of this alive, take as many with you as you can. Armor Crewmans are usually killed on sight.</li>
				<li><B>5. Haul ammo.</B> Magazines, fuel tanks can be attached to armor or worn instead of belt. You better do that.</li><BR><BR>

				<h3><B>Gunner:</B></a></h3>
				<li><B>1. Do not shoot without making sure there is no marines in front of you.</B> Exception: if you have M21 Autocannon and M56 Cupola installed. Then it's exactly your job to lay suppressive fire over marines' heads.</li>
				<li><B>2. Check ammo often.</B> The only thing worse than facing a dangerous enemy is facing one with empty gun.</li>
				<li><B>3. Adapt to situation quickly.</B> Make sure to train switching active weapons as fast as you can. Good combinations of primary and secondary weapons do miracles.</li>
				<li><B>4. Communication is a key.</B> Switch on squad channels. That helps <B>a lot</B>.</li>
				<li><B>5. You are tank commander.</B> It's your duty to order driver where to move and turn. Forgetting this will lead to significant decrease in combat efficiency.</li>
				<li><B>6. Shooting at targets danger close to marines is very bad idea.</B> Especially with M5. Just don't. Exception: one marine uncapable to fight with no marines near to help them. Then shoot and call medic immediately.</li><BR>

				<h3><B>Driver:</B></a></h3>
				<li><B>1. Less initiative.</B> Making sudden turn without warning not only will make gunner miss, but also may result in serious FF toward marines. Always follow gunner's orders unless tip #2.</li>
				<li><B>2. You are the one responsible for tank safety.</B> Gunner is busy with shooting and may not notice danger coming from other side. Carefully listen to squads' and command channels. If you are sure that tank is in danger and you need to pull out, do it.</li>
				<li><B>3. Target priority.</B> Turning towards enemy with marines in the way is very bad idea, unless you have M21 Autocannon and M56 "Cupola" installed. Better keep an eye on other directions.</li>
				<li><B>4. Crush them. Or don't.</B> Sometimes there are situations when you can and should drive over enemy. Driving over fallen marines to cover them from enemy with your armor often considered a good move, despite inflicted injures. Sometimes.</li>
				<li><B>5. Front toward enemy.</B> Always keep tank facing enemy or direction potential enemies will come from. No exceptions.</li>
				<li><B>6. Use binoculars.</B> They will help you to assess situation around tank better and you will be able to help gunner, by adjusting position allowing other AC to hit contacts.</li>
				<li><B>7. Angles matter.</B> Remember, that tank's Primary Weaponry has only 45 degrees arc of fire. Keep that in mind, when getting into firing position.</li><BR><BR>
				We hope this Technial Manual helped you to understand strong and weak points of M46 "Stingray" and you will serve on it for a long time.<BR>
				Good luck, marine. Hoorah!<BR><BR>

				<h1><a name="Part_2"><U><B>Part 2: The APC</B></U></a></h1><BR>
				<I>Mobile field infirmary, ammo depot or HQ.</I><BR><BR>

				<h1><a name="Part_1_ru"><U><B>Часть 1: Танк</B></U></a></h1><BR>
				<I>Стальной зверь.</I><BR><BR>

				<h1><a name="General_ru"><B>ОбщаЯ ИнформациЯ</B></a></h1>
				<I>Важные вещи, которые необходимо знать и помнить.</I><BR><BR>

				<li>В первую очередь, вам необходимо знать, что на М46 установлен двигатель МТ45 "RoadHog". Это достаточно мощный двигатель, который в состоЯнии
				довольно быстро доставить танк на нужную позицию (при условии, что вы установили траки). На этом его плюсы заканчиваютсЯ. Как только вы начнете
				устанавливать различные модули, вы сразу заметите падение скорости танка. Это значит, что вам придетсЯ выбирать между скоростью, защищенностью и
				огневой мощью танка. Вес танка можно условить поделить на Легкий, Средний и ТЯжелый класс танка. Очевидно, что ТЯжелый класс будет самым медленным,
				в то времЯ как Легкий класс будет все еще относительно быстрым. Однако вес танка влиЯет не только на скорость его передвижениЯ, он также немного
				влиЯет на точность стрельбы. ТЯжелый танк имеет лучшую устойчивость, что, в теории, положительно скажетсЯ на точности стрельбы. Это так же стоит
				учитывать вам при выборе модулей. ДлЯ того, чтобы не запоминать кучу больших цифр, мы ввели систему "Относительного Веса". Каждый модуль имеет
				"Относительный Вес" (RW) который вы и будете учитывать при подсчете веса танка с вашеими модулЯми. Классы танка делЯтсЯ по весу следующим образом:
				Легкий танк - до 10 RW, Средний танк - от 11 RW до 15 RW и ТЯжелый танк - от 16 RW и выше.<BR>
				<li>М46 имеет усовершенствованную систему боеприпасов, в которой устранен конструктивный недостаток, не позволЯвший разрЯжать оружие полностью, включаЯ
				зарЯженный в оружие магазин. Так же новаЯ система автоматически разрЯжает все магазины оружиЯ пока вы его демонтируете, включаЯ магазин в самом оружии.<BR>
				<li>"Скат" также имеет встроенную Систему Дымовой Завесы М75. При активации она выстреливает две дымовые гранаты в направлении, куда в этот момент
				развернут танк, эффективно скрываЯ танк от противника с данного направлениЯ. В магазин входЯт 10 дымовых гранат, что дает 5 использований.
				Оба ТСа имеют доступ к этой системе. Оба ТСа имеют возможность активировать М75</li>
				<li>Инженеры смогли немного расширить внутреннее пространство, что позволило менЯтьсЯ местами даже когда оба ТСа находЯтсЯ в танке.</li>
				<li>Также они установили новые сенсоры и монитор, отображающий по запросу состоЯние танка, включаЯ: общее состоЯние всех модулей в процентах, количество
				боеприпасов и запасных магазинов, а так же количество оставшихсЯ использований системы М75.</li>
				<li>Был установлен вспомогательный люк в верхней части танка, который позволЯет попасть в танк, даже если задний люк заблокирован.</li>
				<li>В танк была встроена специальнаЯ камера, позволЯющаЯ командованию видеть танк на их консолЯх камер (Armored Vehicle в списке камер).</li>
				<li>Внешний громкоговоритель был починен и теперь исправно работает. Правда, вы сами не сможете услышать, что вы говорите в него.</li>
				<li>Помните, что любой с инженерными навыками уровнЯ боевого инженера может демонтировать, произвести полевой ремонт и установить обратно ваши траки.</li>
				<li>Все модули могут быть починены в Станции Ремонта Модулей в Гараже возле Такнового Вендора.</li>

				<h1><a name="Primary_ru"><B>Основные Оружейные Модули</B></a></h1>
				<li><I>M21 Autocannon.</I> 1RW. ОсновнаЯ легкаЯ танковаЯ автопушка. Спроектирована длЯ легких разведовательных танков. Скорость стрельбы была снижена длЯ введениЯ поддержки IFF системы. Поддерживает два типа снарЯдов: AP(ББ) - 30мм бронебойный; SCR(СКС) - специальный контузЯщий снарЯд длЯ подавлениЯ живой силы противника.</li>
				<li><I>M5 LTB Cannon.</I> 2RW. Основное 86мм танковое орудие. Поддерживает три типа снарЯдов: AP(ББ) - бронебойный снарЯд; HE(ОФ) - осколочно-фугасный снарЯд, длЯ поражениЯ живой силы противника; HEAT(КУ) - кумулЯтивный снарЯд длЯ поражениЯ целей за броней или укреплениЯми.</li>
				<li><I>M74 LTAA-AP Minigun.</I> 3RW. Ну, это миниган. Что еще добавить. Жмите на гашетку и не пробуйте считать пули, голова заболит.</li>

				<h1><a name="Secondary_ru"><B>Дополнительные Оружейные Модули</B></a></h1>
				<li><I>M56 "Cupola".</I> 2RW. Модернизированный М56, точнее и скорострельней. Поддерживает IFF систему.</li>
				<li><I>M8-3 TOW Launcher.</I> 2RW. ПТУР, хорошо пробивает бронированные и не очень цели. Но только в случае прЯмоого попаданиЯ, в противном случае толку немного.</li>
				<li><I>M7 "Dragon" Flamethrower Unit.</I> 2RW. Не дайте себЯ обмануть, это не нормальный огнемет. Эта штука испускает огненные шары. Буквально.</li>
				<li><I>M92 Grenade Launcher.</I> 2RW. ОтправлЯет в полет HEDP гранаты дальше видимости стрелка. Серьезно, оно так и работает.</li><BR><BR>

				<h1><a name="Support_ru"><B>Вспомогательные Модули</B></a></h1>
				<li><I>M40 Integrated Weapons Sensor Array.</I> 1RW. Улучшает точность и скорость стрельбы оружиЯ. Гораздо полезнее, чем кажетсЯ.</li>
				<li><I>M103 Overdrive Enhancer.</I> 1RW. Улучшение двигателЯ. Улучшает как скорость передвижениЯ, так и скорость поворота танка.</li>
				<li><I>M6 Artillery Module.</I> 1RW. Внушительного размера коробок с кучей плат, датчиков и линз. Значительно увеличивает дальность видимости стрелка, попутно добавлЯЯ карту ближайшей местности в визор, что позволЯет видеть землю даже в темноте.</li>

				<h1><a name="Armor_ru"><B>ТанковаЯ БронЯ</B></a></h1>
				<li><I>M65-B.</I> 7RW. СтандартнаЯ бронЯ. ЗолотаЯ середина между защищенностью и весом.</li>
				<li><I>M70 "Caustic".</I> 5RW. СпециальнаЯ бронЯ. Назначение: защищать танк от коррозивных свойств среды на планетах с нестабильной атмосферой.</li>
				<li><I>M66-LC.</I> 4RW. ЛегаЯ бронЯ, предназначеннаЯ длЯ легкого разведовательного танка. Защищенность была пожертвована в угоду легкости и, следовательно, скорости. После первых тестов прототипа была улучшена защита от врезаний в стены./li>
				<li><I>M90 "Paladin".</I> 10RW. ТЯжелаЯ бронЯ длЯ тЯжелого танка. Превращает танк в медленно движущийсЯ бункер. ВысокаЯ защищенность от почти всех видов повреждений.</li>
				<li><I>M37 "Snowplow".</I> 3RW. СпециализированнаЯ бронЯ, оснащеннаЯ многоцелевым тралом-очистителем. Сконструирован длЯ расчистки снега, мин и тому подобного. Имеет высокую защищенность от взрывов, однако в целом защищенность оставлЯет желать лучшего.</li>

				<h1><a name="Treads_ru"><B>Траки</B></a></h1>
				<li><I>M2 Tank Treads.</I> 1RW. Стандартные траки. Удивительным образом благоприЯтно сказываютсЯ на скорости танкаю.</li>
				<li><I>M2-R Tank Treads.</I> 3RW. Укрепленные траки. В три раза тЯжеле стандартных, однако значительно крепче. Присутствует слой схожего с покрытием брони М70.</li><BR><BR>

				<h1><a name="Updates_ru"><B>Новые Особенности</B></a></h1>
				<li>Инженеры обновили системы М46 и установили улучшенное программное обеспечение. ПредставлЯем: Пользовательский Интерфейс. Теперь при нажатии новой кнопки "ACtivate UI" откроетсЯ окно пользовательского интерфейса.</li>
				<li>Внимание! Функционал системы не был протестирован полностью, сообщайте об ошибках в Технический Отдел ОШКМП.</li>

				<h1><a name="Tips_1_ru"><B>Советы ДлЯ новичков</B></a></h1>
				<h3><B>Советы обоим танкистам:</B></a></h3>
				<li><B>1. Контроль темперамента.</B> Всегда найдетсЯ морпех, который будет материтсЯ на танк без причины. Ваш напарник рано или поздно совершит серьезную ошибку. Дышите глубже, длЯ танка требуетсЯ спокойствие и сосредоточенность, иначе от него будет только вред.</li>
				<li><B>2. Важность командной работы.</B> Как между вами, так и между танком и морпехами. Танк и пехота должны усиливать друг друга. Учитывайте это, уезжаЯ в одиночку куда-либо.</li>
				<li><B>3. Паника смертельна.</B> Запаникуете - вам конец. Все просто.</li>
				<li><B>4. ВысокаЯ цена.</B> Если вам стало Ясно, что живыми вы не уйдете, постарайтесь прихватить с собой как можно больше противников. По Танкистам обычно стрелЯют на поражение.</li>
				<li><B>5. Все свое ношу с собой.</B> Магазины, топливные баки длЯ оружиЯ можно носить вместо поЯса или прицепить к броне. Советуем это сделать.</li><BR><BR>

				<h3><B>Советы стрелку:</B></a></h3>
				<li><B>1. Не стрелЯйте, не удостоверившись, что перед вами нат морпехов.</B> Исключение: если у вас установлены М21 Автопушка и М56 "Cupola". В таком случае ваша задача именно поливать противника перед морпехами огнем на подавление.</li>
				<li><B>2. Ведите учет боеприпасов.</B> Хуже встречи с опасным противником может быть только отсутствие боеприпасов.</li>
				<li><B>3. Приспосабливайтесь к ситуации.</B> Потренируйтесь быстро переключать оружие. Правильные сочетаниЯ Основного и Второстепенного оружиЯ творЯт чудеса.</li>
				<li><B>4. Ценность информации.</B> Подключите каналы отрЯдов в вашем наушнике. Это <B>сильно</B> помогает.</li>
				<li><B>5. Вы - командир танка.</B> Это ваша обЯзанность отдавать приказы мехводу куда двигатьсЯ и поворачивать. Эффективность танка сильно снижаетсЯ при забывании этого факта.</li>
				<li><B>6. СтрелЯть по целЯм в близости от морпехов плохаЯ идеЯ.</B> Особенно с М5. Не стоит этого делать. Исключение: один морпех, неспособный к бою, без морпехов поблизости, которые могли бы помочь. В таком случае стрелЯйте и немедленно зовите медика.</li><BR>

				<h3><B>Советы мехводу:</B></a></h3>
				<li><B>1. Поменьше инициативы.</B> Резкие повороты без предупреждениЯ не только заставЯт стрелка промахнутьсЯ, они также могут привести к серьезному огню по своим. Всегда следуйте приказам стрелка, за исключением пункта #2.</li>
				<li><B>2. Вы ответственны за целостность танка.</B> Стрелок занЯт стрельбой и может не заметить угрозу с другого направлениЯ. Вслушивайтесь в переговоры на каналах командованиЯ и отрЯдов. Если вы считаете, что танку грозит опасность и нужно отходить, отходите.</li>
				<li><B>3. Приоритет целей.</B> РазворачиватьсЯ в сторону противника, перед которым находЯтсЯ морпехи очень плохаЯ идеЯ, если только у вас не установлены М21 Автопушка и М56 "Cupola". Лучше следите за другими направлениЯми.</li>
				<li><B>4. Сокрушите их. Или нет.</B> В некоторых ситуациЯх вам предоставитьсЯ возможность переехать противника. Советуем это сделать. Также иногда стоит переехать упавших морпехов, чтобы прикрыть их от противника своей броней, несмотрЯ на нанесенный им вред. Иногда.</li>
				<li><B>5. НаправлЯть на врага.</B> Всегда держитесь передом к противнику или направлению, откуда противник должен поЯвитсЯ.. Без исключений.</li>
				<li><B>6. Используйте бинокль.</B> Он поможет лучше понимать ситуацию вокруг вас, а также позволит вам помогать стрелку с наводкой на противника, корректируЯ позицию танка.</li>
				<li><B>7. Углы прицеливаниЯ.</B> Помните, что у основного орудиЯ танка сектор прицеливаниЯ равен 45 градусам. Учитывайте это при выходе на огневой рубеж.</li><BR><BR>

				<h1><a name="Part_2_ru"><U><B>Часть 2: БТР</B></U></a></h1><BR>
				<I>Мобильный полевой лазарет, склад боеприпасов или штаб.</I><BR><BR>

				Мы надеемсЯ, что данной Техническое Руководство помогло вам понЯть как именно снарЯдить свой танк с учетом вашего опыта и данных по операции.<BR>
				Удачи, морпехи. Ура и к черту!

				</body>
			</html>
			"}