/*
 * < SUB QUERY 서브쿼리 >
 * 
 * 하나의 메인 SQL(SELECT, INSERT, UPDATE, DELETE, CREATE, ...)안에 포함된
 * 또 하나의 SELECT문
 * 
 * MAIN SQL문의 보조역할을 하는 쿼리문
 */

-- 간단 서브쿼리 예시
SELECT * FROM EMPLOYEE;
-- 박세혁 사원과 부서가 같은 사원들의 사원명 조회

-- 1) 먼저 박세혁 사원의 부서코드 조회
SELECT
       DEPT_CODE
  FROM
       EMPLOYEE
 WHERE
       '박세혁' = EMP_NAME;

-- 2) 부서코드가 D5인 사원들의 사원명 조회
SELECT
       EMP_NAME
  FROM
       EMPLOYEE
 WHERE
       DEPT_CODE = 'D5';

-- 위 두 단계를 하나의 쿼리문으로 합치기
SELECT
       EMP_NAME
  FROM
       EMPLOYEE
 WHERE
       DEPT_CODE = (SELECT
					       DEPT_CODE
					  FROM
					       EMPLOYEE
					 WHERE
					       '박세혁' = EMP_NAME);

------------------------------------------------------------
SELECT
       (SELECT EMP_NAME )
  FROM
       EMPLOYEE
 WHERE
       DEPT_CODE = (SELECT
                           EMP_NAME,
					       DEPT_CODE
					  FROM
					       (SELECT EMP_NAME, DEPT_CODE 
					          FROM EMPLOYEE)
					 WHERE
					       EMP_ID = (SELECT 
                                            EMP_ID
                                       FROM
                                            EMPLOYEE
                                      WHERE
                                            EMP_NAME = '박세혁'
                                        AND
                                            DEPT_CODE = 'D5'));


------------------------------------------------------------
-- 간단한 서브쿼리 예시 두 번째
-- 전체 사원의 평균 급여보다 더 많은 급여를 받고 있는 사원들의 사번, 사원명을 조회

-- 1) 전체 사원의 평균 급여 구하기
SELECT
       AVG(SALARY)
  FROM
       EMPLOYEE; -- 대략 3131140원

-- 2) 급여가 3131140원 이상인 사원들의 사번, 사원명
SELECT
       EMP_ID
     , EMP_NAME
  FROM
       EMPLOYEE
 WHERE
       SALARY >= 3131140;

-- 위의 두 단계를 하나로 합치기
SELECT
       EMP_ID
     , EMP_NAME
  FROM
       EMPLOYEE
 WHERE
       SALARY >= (SELECT
				         AVG(SALARY)
				    FROM
				         EMPLOYEE);
------------------------------------------------------------------
/*
 * 서브쿼리의 분류
 * 
 * 서브쿼리를 수행한 결과가 몇 행 몇 열이냐에 따라서 분류됨
 * 
 * - 단일행 [단일열] 서브쿼리 : 서브쿼리 수행 결과가 딱 1개일 경우
 * - 다중행 [단일열] 서브쿼리 : 서브쿼리 수행 결과가 여러 행일 때
 * - [단일열] 다중열 서브쿼리 : 서브쿼리 수행 결과가 여러 열일 때
 * - 다중행 다중열 서브쿼리   : 서브쿼리 수행 결과가 여러 행, 여러 열 일때
 * 
 * => 수행 결과가 몇 행 몇 열이냐에 따라서 사용할 수 있는 연산자가 다름
 */

/*
 * 1. 단일 행 서브쿼리(SINGLE ROW SUBQUERY)
 * 
 * 서브쿼리의 조회 결과값이 오로지 1개 일 때
 * 
 * 일반 연산자 사용(=, !=, >, < ...)
 */
-- 전 직원의 평균 급여보다 적게 받는 사원들의 사원명, 전화번호 조회

-- 1. 평균 급여 구하기
SELECT
       AVG(SALARY)
  FROM
       EMPLOYEE; --> 결과값 : 오로지 1개의 값
       
SELECT
       EMP_NAME
     , PHONE
  FROM
       EMPLOYEE
 WHERE
       SALARY < (SELECT
				        AVG(SALARY)
				   FROM
				        EMPLOYEE);	

-- 최저급여를 받는 사원의 사번, 사원명, 직급코드, 급여, 입사일 조회

-- 1. 최저급여 구하기
SELECT
       MIN(SALARY)
  FROM
       EMPLOYEE;

SELECT  
       EMP_ID
     , EMP_NAME
     , JOB_CODE
     , SALARY
     , HIRE_DATE
  FROM
       EMPLOYEE
 WHERE
       SALARY = (SELECT
				        MIN(SALARY)
				   FROM
				        EMPLOYEE);


-- 안준영 사원의 급여보다 더 많은 급여를 받는 사원들의 사원명, 급여 조회
SELECT
       SALARY
  FROM
       EMPLOYEE
 WHERE
       EMP_NAME = '안준영';

SELECT
       EMP_NAME
     , SALARY
  FROM   
       EMPLOYEE
 WHERE
       SALARY > (SELECT
				        SALARY
				   FROM
				        EMPLOYEE
				  WHERE
				        EMP_NAME = '안준영');

-- JOIN도 써먹어야죵
-- 박수현 사원과 같은 부서인 사원들의 사원명, 전화번호, 직급명을 조회하는데 박수현 사원은 제외
-- SQL(Structured Query Language)
SELECT
       DEPT_CODE
  FROM
       EMPLOYEE
 WHERE
       EMP_NAME = '박수현';

SELECT * FROM EMPLOYEE;

SELECT
       EMP_NAME
     , PHONE
     , JOB_NAME
  FROM
       EMPLOYEE
     , JOB
 WHERE
       EMPLOYEE.JOB_CODE = JOB.JOB_CODE
   AND
       DEPT_CODE = 'D5';

SELECT
       EMP_NAME
     , PHONE
     , JOB_NAME
  FROM
       EMPLOYEE
     , JOB
 WHERE
       EMPLOYEE.JOB_CODE = JOB.JOB_CODE
   AND
       DEPT_CODE = (SELECT
					       DEPT_CODE
					  FROM
					       EMPLOYEE
					 WHERE
					       EMP_NAME = '박수현')
   AND
       EMP_NAME != '박수현';

SELECT
       EMP_NAME
     , PHONE
     , JOB_NAME
  FROM
       EMPLOYEE
  JOIN
       JOB USING(JOB_CODE)
 WHERE
       DEPT_CODE = (SELECT
                           DEPT_CODE
                      FROM
                           EMPLOYEE
                     WHERE
                           EMP_NAME = '박수현')
   AND
       EMP_NAME != '박수현';
                       
-------------------------------------------------------------------
-- 부서별 급여 합계가 가장 큰 부서의 부서명, 부서코드, 급여합계 조회
-- 1_1. 각 부서별 급여 합계
SELECT
       SUM(SALARY)
  FROM 
       EMPLOYEE
 GROUP
    BY
       DEPT_CODE;
-- 1_2. 부서별 급여합계 중 가장 큰 급여합
SELECT
       MAX(SUM(SALARY))
  FROM
       EMPLOYEE
 GROUP
    BY
       DEPT_CODE;

SELECT
       SUM(SALARY)
     , DEPT_CODE
     , DEPT_TITLE
  FROM
       EMPLOYEE
  JOIN
       DEPARTMENT ON (DEPT_ID = DEPT_CODE)
-- WHERE
--       SUM(SALARY) = 18000000
 GROUP
    BY
       DEPT_CODE,
       DEPT_TITLE
HAVING
       SUM(SALARY) = 18000000;

-- 합치기
SELECT
       SUM(SALARY)
     , DEPT_CODE
     , DEPT_TITLE
  FROM
       EMPLOYEE
  JOIN
       DEPARTMENT ON (DEPT_ID = DEPT_CODE)
 GROUP
    BY
       DEPT_CODE,
       DEPT_TITLE
HAVING
       SUM(SALARY) = (SELECT
					         MAX(SUM(SALARY))
					    FROM
					         EMPLOYEE
					   GROUP
					      BY
					         DEPT_CODE);
---------------------------------------------------------------------
-- 자! 우리가 지금 하고 있는 작업이 어떤걸 하고 있는 건가요?
-- DB에다가 주고받고 --> 콤퓨타 작업
------------------------------------------------------------------------
/*
 * 2. 다중 행 서브쿼리
 * 서브쿼리의 조회 결과값이 여러 행일때
 * 
 * - IN(10, 20, 30) : 여러 개의 결과값 중 한 개라도 일치하는 값이 있다면
 */
-- 각 부서별 최고급여를 받는 사원의 이름, 급여 조회
SELECT 
       MAX(SALARY)
  FROM
       EMPLOYEE
 GROUP
    BY
       DEPT_CODE; -- 830, 390, 366, 255, 289, 376, 750

SELECT * FROM EMPLOYEE;

SELECT
       EMP_NAME
     , SALARY
  FROM
       EMPLOYEE
 WHERE
       -- SALARY = 8300000 OR SALARY = 3900000 OR 
       SALARY IN (SELECT 
				         MAX(SALARY)
				    FROM
				         EMPLOYEE
				   GROUP
				      BY
				         DEPT_CODE);

-- 이승철 사원 또는 선승제 사원과 같은 부서인 사원들의 사원명, 핸드폰번호 조회
SELECT
       DEPT_CODE
  FROM
       EMPLOYEE
 WHERE
       EMP_NAME IN ('이승철', '선승제');

SELECT
       EMP_NAME
     , PHONE
  FROM
       EMPLOYEE
 WHERE
       DEPT_CODE IN (SELECT
					        DEPT_CODE
					   FROM
					        EMPLOYEE
					  WHERE
					        EMP_NAME IN ('이승철', '선승제'));
      
SELECT * FROM JOB;
-- 인턴(수습사원) < 사원 < 주임 < 대리 < 과장 < 차장 < 부장
SELECT * FROM EMPLOYEE;
-- 대리직급임에도 불구하고 과장보다 급여를 많이 받는 대리가 존재한다!!

-- 1) 과장들은 얼마를 받고 있는가

-- '과장'
SELECT
       SALARY
  FROM
       EMPLOYEE E
     , JOB J
 WHERE
       J.JOB_CODE = E.JOB_CODE
   AND
       JOB_NAME = '과장'; -- 220, 250, 232, 376, 750
       
-- 2) 위의 급여보다 높은 급여를 받고 있는 대리의 사원명, 직급명, 급여
SELECT
       EMP_NAME
     , JOB_NAME
     , SALARY
  FROM
       EMPLOYEE E
     , JOB J
 WHERE
       E.JOB_CODE = J.JOB_CODE
   AND
   	  -- SALARY > ANY(2200000, 2500000, 23200000)
       --SALARY > 2200000 OR SALARY > 2500000 OR 
   	   SALARY > ANY (SELECT
					        SALARY
					   FROM
					        EMPLOYEE E
					      , JOB J
					  WHERE
					        J.JOB_CODE = E.JOB_CODE
					    AND
					        JOB_NAME = '과장')
   AND
       JOB_NAME = '대리';

/*
 *  X(컬럼) > ANY(값, 값, 값)
 * 	X의 값이 ANY괄호안의 값 중 하나라도 크면 참
 * 
 *  > ANY(값, 값, 값) : 여러 개의 결과값중 하나라도 "클"경우 참을 반환
 * 
 *  < ANY(값, 값, 값) : 여러 개의 결과값중 하나라도 "작을"경우 참을 반환
 */

-- 과장직급인데 모든 차장직급의 급여보다 더 많이 받는 직원
SELECT
       SALARY
  FROM
       EMPLOYEE
  JOIN
       JOB USING(JOB_CODE)
 WHERE
       JOB_NAME = '차장';

SELECT
       EMP_NAME
  FROM
       EMPLOYEE
  JOIN
       JOB USING(JOB_CODE)
 WHERE
       SALARY > ALL(SELECT
					       SALARY
					  FROM
					       EMPLOYEE
					  JOIN
					       JOB USING(JOB_CODE)
					 WHERE
					       JOB_NAME = '차장')
   AND   
       JOB_NAME = '과장';
---------------------------------------------------------------
/*
 * 3. 다중 열 서브쿼리
 * 
 * 조회결과는 한 행이지만 나열된 컬럼의 수가 다수개일 때
 */
SELECT * FROM EMPLOYEE;
-- 박채형 사원과 같은 부서코드, 같은 직급코드에 해당하는 사원들의 사원명, 부서코드, 직급코드조회
SELECT
       DEPT_CODE
     , JOB_CODE
  FROM
       EMPLOYEE
 WHERE
       EMP_NAME = '박채형'; -- D5 / J5

-- 사원명, 부서코드, 직급코드 부서코드 == D5 + 직급코드 == J5
SELECT
       EMP_NAME
     , DEPT_CODE
     , JOB_CODE
  FROM
       EMPLOYEE
 WHERE
       DEPT_CODE = 'D5'
   AND
       JOB_CODE = 'J5';
     
SELECT
       EMP_NAME
     , DEPT_CODE
     , JOB_CODE
  FROM
       EMPLOYEE
 WHERE
       DEPT_CODE = (SELECT
					       DEPT_CODE
					  FROM
					       EMPLOYEE
					 WHERE
					       EMP_NAME = '박채형')
   AND
       JOB_CODE = (SELECT
					      JOB_CODE
					 FROM
					      EMPLOYEE
					WHERE
					      EMP_NAME = '박채형');
     
SELECT
       EMP_NAME
     , DEPT_CODE
     , JOB_CODE
  FROM
       EMPLOYEE
 WHERE
       (DEPT_CODE, JOB_CODE) = (SELECT
								       DEPT_CODE
								     , JOB_CODE
								  FROM
								       EMPLOYEE
								 WHERE
								       EMP_NAME = '박채형');
----------------------------------------------------------------
/*
 * 4. 다중 행 다중 열 서브쿼리
 * 서브쿼리 수행 결과가 행도 많고 열도 많음
 */

-- 각 직급별로 최고 급여를 받는 사원들 조회(이름, 직급코드, 급여)
SELECT
       JOB_CODE
     , MAX(SALARY)
  FROM
       EMPLOYEE
 GROUP
    BY
       JOB_CODE;

SELECT
       EMP_NAME
     , JOB_CODE
     , SALARY
  FROM 
       EMPLOYEE
 WHERE
       (JOB_CODE, SALARY) IN (SELECT
							         JOB_CODE
							       , MAX(SALARY)
							    FROM
							         EMPLOYEE
							   GROUP
							      BY
							         JOB_CODE);

--------------------------------------------------------------
/*
 * 5. 인라인 뷰(INLINE-VIEW)
 * 
 * FROM 절에 서브쿼리를 작성
 * 
 * SELECT문의 수행결과(Result Set)을 테이블 대신 사용
 * 
 * 6. 스칼라 서브쿼리(Scalar Subquery)
 * 
 * 주로 SELECT 절에 사용하는 쿼리를 의미(WHERE나 FROM이나 다 쓸 순 있음)
 * 메인쿼리 실행 마다 서브쿼리가 실행될 수 있으므로 성능이슈가 생길 수 있음
 * 그렇게 때문에 JOIN으로 대체하는 것이 일반적으로는 성능상 유리함
 * 단, 캐싱이 되기 때문에 동일한 결과에 대해선 성능상 JOIN보다 뛰어날 수도 있음
 * 스칼라 쿼리는 반드시 단 한개의 값만을 반환해야함
 */
-- 스칼라 예시
-- 사원의 사원명과 부서명을 조회
SELECT
       EMP_NAME
     , DEPT_TITLE
  FROM
       EMPLOYEE
  JOIN
       DEPARTMENT ON (DEPT_CODE = DEPT_ID);

SELECT
       EMP_NAME
     , (SELECT DEPT_TITLE FROM DEPARTMENT WHERE E.DEPT_CODE = DEPT_ID)
  FROM
       EMPLOYEE E;

-- 간단하고 시원하게 인라뷰 한 번 그냥 써보기만 하기
-- 사원들의 이름, 보너스 포함 연봉 조회하고 싶음
-- 단 보너스포함 연봉이 4000만원 이상인 사원만 조회
/*
SELECT
       EMP_NAME AS "사원이름"
     , (SALARY + SALARY * NVL(BONUS, 0)) * 12 AS "보너스 포함 연봉"
  FROM
       EMPLOYEE
 WHERE  
       "보너스 포함 연봉" > 40000000;
*/
SELECT 
       "사원이름"
     , "보너스 포함 연봉"
  FROM
       (SELECT
		       EMP_NAME AS "사원이름"
		     , (SALARY + SALARY * NVL(BONUS, 0)) * 12 AS "보너스 포함 연봉"
		  FROM
		       EMPLOYEE)
 WHERE
       "보너스 포함 연봉" > 40000000;

--> 인라인 뷰를 주로 사용하는 예(클래식)
--> TOP-N 분석 : DB상에 있는 값들 중 최상위 N개의 데이터를 보기위해서 사용

SELECT * FROM EMPLOYEE;
-- 전 직원들 중 급여가 가장 높은 상위 5명 줄 세우기해서 조회

-- * ROWNUM : 오라클에서 자체적으로 제공해주는 컬럼, 조회된 순서대로 순번을 붙여줌
SELECT
       EMP_NAME
     , SALARY
     , ROWNUM
  FROM
       EMPLOYEE;

SELECT				-- 3
       ROWNUM
     , EMP_NAME
     , SALARY
  FROM				-- 1
       EMPLOYEE
 WHERE				-- 2
       ROWNUM <= 5
 ORDER				-- 4
    BY
       SALARY DESC;

-- ORDER BY절을 이용해서 줄세우기 먼저 수행
SELECT 
       EMP_NAME
     , SALARY
  FROM
       (SELECT 
               EMP_NAME
             , SALARY
          FROM
               EMPLOYEE
         ORDER
            BY
               SALARY DESC)
 WHERE
       ROWNUM <= 5;
------------------------------------------------------------
-- 아 모던한 방법 쓰고 싶다.
SELECT
       EMP_NAME
     , SALARY
  FROM
       EMPLOYEE
 ORDER
    BY
       SALARY DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;  
-- 0개를 건너 뛰고 그 다음 5행을 반환받겠다.
       
       
       
       
-- 클래스와 객체 
-- 클래스 : 객체를 생성하기 위한 템플릿 상태(필드), 행위(메서드) 정의함
-- 객체(인스턴스) : 클래스를 바탕으로 실제 메모리에 할당된 실체 
-- 필드(멤버변수) : 객체의 데이터를 저장하는 변수
-- 메서드 : 객체가 수행할 수 있는 작업을 정의한 코드블럭
-- 생성자 : 객체를 생성할 때 사용하는 특수한 기능의 메서드
-- this : 현재 객체를 참조할 때 사용 객체 자기자신의 주소값을 가지고 있음
      -- 주로 필드와 매개변수의 이름이 같을 때 구분하기 위한 용도로 사용함!

-- 상속
-- 개념 : 부모클래스의 특성(자료형, 필드, 메서드)을 자식클래스가 물려받는 것
-- 목적 : 코드 재사용성 증가, 계층적 관계 표현, 다형성 구현의 기반
-- 구현방법 : extends 키워들 사용
-- super키워드 : 부모클래스의 객체주소를 담고있음
-- 메서드 오버라이딩 : 부모클래스의 메소드를 자식클래스에서 재정의
-- 제약사항 : 자바는 단일 상속만 지원
-- 모든 클래스는 Object클래스를 상속 받아서 사용할 수 있음

-- 다형성
-- 정의: 같은 자료형이지만 실행결과가 다양하게 객체를 이용할 수 있는 성질
-- UpCasting : 자식객체를 부모타입으로 참조해서 사용할 수 있는 성질(자동형변환)
-- DownCasting : 부모 타입을 자식타입으로 사용해야 할때 (강제형변환 필요)
-- MethodDispatch : 실행 시점에 객체의 실제 타입에 맞는 메서드가 호출됨(동적 바인딩)

-- 캡슐화
-- 목적 : 객체의 속성과 행위를 하나로 묶고, 실제 구현내용을 외부로부터 감춤
-- 접근제어자 : private으로 필드를 선언
-- getter / setter : 필드에 접근하고 값을 변경하기 위한 메소드
-- 장점 : 코드 변경의 영향을 최소화, 유지보수 용이성, 객체 무결성을 유지

-- 추상화
-- 개념 : 공통적인 속성이나 기능을 추출하여 정의하는 것
-- 추상클래스 : abstact 키워드를 붙여서 선언
-- 목적 : 상속을 통한 확장을 염두해두고 설계 공통된 기능을 구현하고 자식 클래스마다의
-- 고유한 기능은 따로따로 오버라이딩해서 구현할 목적

-- 인터페이스
-- 정의 : 클래스들이 구현해야하는 메서드들의 집합을 정의
-- 인터페이스 상속 : 인터페이스가 다른 인터페이스를 상속 가능, 다중 구현도 가능
-- 마커 인터페이스 : 메서드가 없는 인터페이스 (Serializable)
-- 함수형 인터페이스 : 단 하나의 추상메서드만을 가진 인터페이스(@FuntionalInterface)

-- 컬렉션 프레임워크
-- List : index개념이 있음, Value만 저장, 중복값 허용
-- Set  : 순서 보장해 주지않음, index개념 없음 Value만 저장, 중복값을 허용하지 않음
-- Map  : 키-값 쌍으로 저장, 순서는 보장해주지(index개념없음)
-- Collenctions 
-- Iterator : 컬렉션 요소를 순회하는 표준 방법

-- 예외처리
-- 예외(Exception) : 프로그램 실행 중 발생하는 예기치 않는 사건
-- CheckedException : 컴파일러가 처리를 강제함
-- UncheckedException : 컴파일러가 처리를 강제하지 않음
-- Error : 코드로 해결이 안됨, 복구 불가능
-- 예외처리 구문 : try-catch, try-catch(multi-catch), try-catch-finally
--              try-with-resources
-- 예외 전파 : throws키워드를 이용해서 메서드 호출 부 전달
--         : throw 억지로 예외를 발생 시킬 수 있음




















       
       







