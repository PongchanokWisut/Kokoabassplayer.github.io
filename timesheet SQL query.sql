SELECT 
    us.email
    ,us.name
    ,us.emp_id AS Employee_ID
    ,UPPER(SUBSTRING_INDEX(us.dept_code, '-', 1)) AS departments
    ,UPPER(SUBSTRING(us.dept_code,INSTR(us.dept_code,'-')+1,20)) AS sections
    ,UPPER(us.bunit_code) AS 'BU'
    ,COALESCE(UPPER(BU_Proj),'') AS BU_Proj
    ,period_code AS PERIOD
    ,UPPER(mhw.status) AS STATUS
    ,TypeCharge
    ,CAST(SUM(COALESCE(hours,0)) AS DECIMAL(10,2)) AS emp_fill_hours
    ,mp.workday_plan
    ,mp.workday_plan_hour
FROM  users us
LEFT JOIN 
        (
	SELECT 
            ts.emp_id
            ,ts.code AS ts_code
            ,ts.id AS ts_id
            ,p.bunit_code AS 'BU_Proj'
            ,period_code
            ,tss.status 
            ,CASE WHEN is_chargeable  = 0 THEN  'Non - Chargable' 
                  ELSE 'Chargeable'  END  AS  TypeCharge
            ,COALESCE(hours,0) hours
            ,ts.created_at
            ,ts.updated_at
            ,ts.deleted_at     
	FROM   `timesheets` ts 
	LEFT  JOIN `periods` pr 
            ON pr.code = ts.period_code
	LEFT  JOIN manhours mh 
            ON mh.tsheet_code = ts.code
	LEFT JOIN timesheet_statuses tss 
            ON tss.tsheet_code = ts.code
	    AND tss.id = ts.status_id
	LEFT JOIN tasks t 
            ON t.project_code = mh.project_code
            AND t.code = mh.task_code
	LEFT JOIN projects p 
            ON p.code = t.project_code 
	WHERE 
	period_code >= '2005-1' 
        AND mh.deleted_at IS NULL 
        AND ts.deleted_at IS NULL 
        ) mhw
ON us.emp_id  = mhw.emp_id
LEFT JOIN 
	(
	SELECT
		CODE
		,workday_real AS workday_plan
		,(workday_real *8) AS workday_plan_hour
	FROM
		(
		SELECT
			CODE
			,pr.start_Date
			,pr.end_Date
			,
			(
			(SELECT  5* (DATEDIFF(pr.end_Date, pr.start_Date) DIV 7) + MID('1234555512344445123333451222234511112345001234550'
			, 7 * WEEKDAY(pr.Start_Date) + WEEKDAY(pr.end_Date) + 1, 1)
			)
			-
			((SELECT COUNT(*) FROM holidays WHERE DATE >=pr.start_Date AND DATE<=pr.end_Date))
			)workday_real
			
		FROM `periods` pr
		)dayofp
	) mp
ON period_code = mp.CODE
WHERE  us.emp_id <> '123456'
AND UPPER(us.name) NOT LIKE '%TEST%'
AND us.deleted_at IS NULL
AND period_code IS NOT NULL
GROUP BY 
    us.email
    ,us.name
    ,period_code
    ,us.dept_code
    ,us.bunit_code
    ,BU_Proj
    ,mhw.status
    ,TypeCharge
    ,us.emp_id
    ,mp.workday_plan
    ,mp.workday_plan_hour