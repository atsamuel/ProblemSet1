**************************************************************
*
* Autores: Arispe, Condor, Migue,Paganini
* Tema: PS1 de Eco Aplicada 
* 
**************************************************************



cd "D:\Maestrías\USanAndres\3er Trim\Eco Aplicada\Tutoriales"

use data_russia.dta, clear

/*1. Como podrán observar, la base de datos está muy sucia. Idealmente, todas las variables
deberían ser numéricas. Utilizando los comandos replace, split, destring
y encode, emprolijen la base. Se les recomienda que utilicen loops para hacer los
cambios. Pueden ahorrar mucho tiempo!
*/

des

foreach i in hipsiz totexpr {
	split `i', parse(" ") gen(`i')
	replace `i'3="" if `i'3==","
	replace `i'3=subinstr(`i'3,",",".",.)
	destring `i'3, gen(`i'_ns)
}
foreach i in obese satlif {
	replace `i'="" if `i'=="."
}

replace satlif="1" if satlif=="one"
replace satlif="2" if satlif=="two"
replace satlif="3" if satlif=="three"
replace satlif="4" if satlif=="four"
replace satlif="5" if satlif=="five"

foreach i in sex obese {
	encode `i', gen(`i'_ns)
}

foreach i in monage satlif waistc {
	destring `i', gen(`i'_ns)
}


/*2. ¿Hay alguna variable que tenga más del 5% de valores faltantes?
*/

codebook _all


/*3. Cuando uno trabaja con datos, es normal encontrarse variables o observaciones
que pueden considerarse “irregulares” (por ejemplo, ingreso con valores negativos
o gastos mayores a ingresos). Procedan a buscar si hay observaciones de este
tipo. Expliquen cómo lo hacen. Si encuentran algún valor irregular, reemplácenlo
con missing.
*/

sum *_ns, det
hist totexpr_ns
kdensity totexpr_ns

/*4.Ahora el objetivo es que ordenen los datos. La primera variable que aparezca en
la base debería ser el id del individuo, la segunda el sitio (site) donde se encuentra
y la tercera el sexo (sex). Luego, ordenen las filas de mayor a menor según totexpr.
*/

order id site sex
gsort + totexpr

/*5. Siempre que trabajamos con datos, tenemos que conocer la base. Hagan un cuadro
con estadísticas descriptivas del sexo, la edad en años, la satisfacción con la
vida, la circunferencia de la cintura, la circunferencia de la cadera y el gasto real
(totexpr). Asegúrense de que las variables tengan etiquetas. Recuerden siempre
comentar los resultados de una tabla.
*/

estpost summarize *_ns

esttab using "ResultsTable.tex", cells("mean(fmt(%8.2f))" "sd(fmt(%8.2f))" "min(fmt(%8.2f))" "max(fmt(%8.2f))") ///
	replace booktabs compress

/*6. Supongan que hay un determinado paper que se llama “Hips don’t lie” (Shakira,
2005) que dice que las caderas de los hombres son mayores que la de las mujeres.
a. Presenten un gráfico comparando la distribución de hipsiz para los hombres
y para las mujeres.
*/

tabstat hipsiz_ns, by(sex) s(mean p50 min max sd)
graph bar hipsiz_ns, over(sex_ns)
twoway kdensity hipsiz_ns if sex_ns==1 || kdensity hipsiz_ns if sex_ns==2

/*
b. Hagan un test de medias usando las variables hipsiz y sex. El comando que
tienen que usar es ttest. Presenten y comenten los resultados.
*/
ttest hipsiz_ns, by(sex)


/*7. Finalmente, supongan que quieren correr una regresión para explicar la felicidad
de las personas (satli f ) en función de variables explicativas como sexo, edad, altura,
etc. Una vez que decidan qué covariables utilizar:
a. Hagan dos gráficos que los ayuden a pensar en cómo será el resultado de su
estimación. Asegúrense de que esté autocontenido, es decir, que se entienda
de qué trata solo con verlo. Comenten.
*/

gen age=monage_ns/12
xtile t_age=age, n(3)
tabstat age , by(t_age ) s(min max mean)

xtile t_monage=monage_ns, n(3)
lab def t_age 1 "18 a 35 años" 2 "36 a 53" 3 "53 a más"
lab value t_age t_age 

reg satlif_ns i.obese_ns#i.sex_ns i.t_age height totexpr_ns, r
margins i.t_age
mplotoffset, recast(scatter) graphregion(color(white)) title("")  ///Nivel de felicidad medida""en satisfacción de vida
	xtitle("") ytitle("") xsca(ra(2.5 .5)) legend(col(5))

reg satlif_ns i.obese_ns i.sex_ns i.t_age height totexpr_ns, r
estimates store result
coefplot (result, label(Resultados)), drop(_cons) xline(0) baselevels ///
	headings(1.obese_ns ="{bf:Obesidad}" 1.sex_ns = "{bf:Sexo}" 1.t_age = "{bf:Edad en años}") ///
	graphregion(color(white)) scale(0.7) 

/*
b. Estimen dos especificaciones distintas del modelo. Interpreten los coeficientes
y la significatividad estadística.
*/
*Primera regresion
reg satlif_ns i.obese_ns#i.sex_ns monage_ns height totexpr_ns, r
*Segunda regresión
reg satlif_ns i.obese_ns#i.sex_ns monage_ns height totexpr_ns, r
