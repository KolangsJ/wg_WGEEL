  
  
  CREATE OR REPLACE VIEW datawg.landings
AS SELECT t_eelstock_eel.eel_id,
        --CASE
            --WHEN t_eelstock_eel.eel_typ_id = NULL::integer THEN NULL::integer
            --WHEN t_eelstock_eel.eel_typ_id = 5 THEN 4
            --WHEN t_eelstock_eel.eel_typ_id = 7 THEN 6
            --WHEN t_eelstock_eel.eel_typ_id = 4 THEN 4
           -- WHEN t_eelstock_eel.eel_typ_id = 6 THEN 6
            --WHEN t_eelstock_eel.eel_typ_id = 32 THEN 32
            --WHEN t_eelstock_eel.eel_typ_id = 33 THEN 33
            --ELSE NULL::integer
        --END AS eel_typ_id,
        eel_typ_id,
    tr_typeseries_typ.typ_name,
    tr_typeseries_typ.typ_uni_code,
    t_eelstock_eel.eel_year,
    t_eelstock_eel.eel_value,
    t_eelstock_eel.eel_missvaluequal,
    t_eelstock_eel.eel_emu_nameshort,
    t_eelstock_eel.eel_cou_code,
    tr_country_cou.cou_country,
    tr_country_cou.cou_order,
    tr_country_cou.cou_iso3code,
    t_eelstock_eel.eel_lfs_code,
    tr_lifestage_lfs.lfs_name,
    t_eelstock_eel.eel_hty_code,
    tr_habitattype_hty.hty_description,
    t_eelstock_eel.eel_area_division,
    t_eelstock_eel.eel_qal_id,
    tr_quality_qal.qal_level,
    tr_quality_qal.qal_text,
    t_eelstock_eel.eel_qal_comment,
    t_eelstock_eel.eel_comment,
    t_eelstock_eel.eel_datasource
   FROM datawg.t_eelstock_eel
     LEFT JOIN ref.tr_lifestage_lfs ON t_eelstock_eel.eel_lfs_code::text = tr_lifestage_lfs.lfs_code::text
     LEFT JOIN ref.tr_quality_qal ON t_eelstock_eel.eel_qal_id = tr_quality_qal.qal_id
     LEFT JOIN ref.tr_country_cou ON t_eelstock_eel.eel_cou_code::text = tr_country_cou.cou_code::text
     LEFT JOIN ref.tr_typeseries_typ ON t_eelstock_eel.eel_typ_id = tr_typeseries_typ.typ_id
     LEFT JOIN ref.tr_habitattype_hty ON t_eelstock_eel.eel_hty_code::text = tr_habitattype_hty.hty_code::text
     LEFT JOIN ref.tr_emu_emu ON tr_emu_emu.emu_nameshort::text = t_eelstock_eel.eel_emu_nameshort::text AND tr_emu_emu.emu_cou_code = t_eelstock_eel.eel_cou_code::text
  WHERE (t_eelstock_eel.eel_typ_id = ANY (ARRAY[4, 6, 32])) AND (t_eelstock_eel.eel_qal_id = ANY (ARRAY[1, 2, 4]));
  --WHERE (t_eelstock_eel.eel_typ_id = ANY (ARRAY[4, 6, 5, 7, 32, 33])) AND (t_eelstock_eel.eel_qal_id = ANY (ARRAY[1, 2, 4]));


-- CHECK for issue # 296

SELECT x.* FROM datawg.t_series_ser x
WHERE ser_nameshort ='BeeGY';



drop table if exists ref.tr_model_mod cascade;

create table ref.tr_model_mod (
mod_nameshort text not null,
mod_description text,
constraint tr_model_mod_pkey primary key (mod_nameshort)
);
grant all on ref.tr_model_mod to wgeel;
grant select on ref.tr_model_mod to wgeel_read;

drop table if exists datawg.t_modelrun_run cascade;
create table datawg.t_modelrun_run(
run_id serial4,
run_date date not null,
run_mod_nameshort text not null,
run_description text,
constraint tr_modelrun_run_pkey primary key (run_id),
constraint c_fk_run_mod_nameshort foreign key (run_mod_nameshort) references ref.tr_model_mod(mod_nameshort) on update cascade on delete cascade
);


grant all on datawg.t_modelrun_run to wgeel;
grant select on datawg.t_modelrun_run to wgeel_read;


drop table if exists datawg.t_modeldata_dat cascade;
create table datawg.t_modeldata_dat(
dat_id serial4,
dat_run_id int4 not null,
dat_ser_id int4 not null,
dat_ser_year int4 not null,
dat_das_value numeric,
constraint tr_model_mod_pkey primary key (dat_id),
constraint c_uk_modeldata_das_id_run_id unique(dat_run_id,dat_ser_year,dat_ser_id),
CONSTRAINT c_fk_dat_ser_id FOREIGN KEY (dat_ser_id) REFERENCES datawg.t_series_ser(ser_id) ON UPDATE CASCADE on delete cascade,
constraint c_fk_dat_run_id foreign key (dat_run_id) references datawg.t_modelrun_run(run_id) on update cascade on delete cascade
);

grant all on datawg.t_modeldata_dat to wgeel;
grant select on datawg.t_modeldata_dat to wgeel_read;

UPDATE datawg.t_series_ser
  SET (ser_qal_id, ser_qal_comment)=(3,'Duplicated series from BeeG, this series will not be used in the analysis')
  WHERE ser_id=317; 





ALTER SEQUENCE "ref".tr_metrictype_mty_mty_id_seq RESTART WITH 27;
UPDATE "ref".tr_metrictype_mty SET (mty_name,mty_method,mty_individual_name) =('female_proportion', 'check method in method_sex','is_female(1=female,0=male)') WHERE mty_name ='female_proportion (from size)';

/* fix changes
UPDATE "ref".tr_metrictype_mty SET (mty_name,mty_method,mty_individual_name) =
('method_sex_(1=visual,0=use_length)',NULL,'method_sex_(1=visual,0=use_length)')
WHERE mty_id =27;

SELECT * FROM ref.tr_metrictype_mty WHERE mty_id =27;
UPDATE "ref".tr_metrictype_mty
  SET mty_individual_name='method_sex_(1=visual,0=use_length)',mty_name='method_sex_(1=visual,0=use_length)',mty_description='Method used for sex determination',mty_method=''
  WHERE mty_id=27;
UPDATE "ref".tr_metrictype_mty
  SET mty_individual_name='anguillicola_presence(1=present,0=absent)',mty_name='anguillicola_proportion',mty_method='check method in method_anguillicola'
  WHERE mty_id=8;
UPDATE "ref".tr_metrictype_mty
  SET mty_description='Method used for anguillicola intensity and proportion'
  WHERE mty_id=28;
*/



/*
 * SELECT * FROM pg_stat_get_activity(NULL::integer) 
 */
 



-- note the names is the same in individual and group series
INSERT INTO "ref".tr_metrictype_mty 
(mty_name,
mty_individual_name,
mty_description,
mty_type,
mty_method,
mty_uni_code,
mty_group,
mty_min,
mty_max) 
SELECT
'method_sex_(1=visual,0=use_length)' AS mty_name
,'method_sex_(1=visual,0=use_length)' AS mty_individual_name
,mty.mty_description
,mty.mty_type
,NULL AS mty_method
,mty.mty_uni_code
,mty.mty_group
,mty.mty_min
,mty.mty_max
FROM "ref".tr_metrictype_mty mty WHERE 
mty_name = 'female_proportion (from size)';


UPDATE "ref".tr_metrictype_mty SET (mty_name,mty_method, mty_individual_name) = 
('anguillicola_proportion (visual)' , 'Visual inspection of the swimbladder','anguillicola_presence_visual(1=present,0=absent)')
WHERE mty_name ='anguillicola_proportion';

/* fix since we changed our mind, not to be run again
UPDATE "ref".tr_metrictype_mty SET (mty_name,mty_method, mty_individual_name) = 
('anguillicola_proportion' , 'Check method in method_anguillicola','anguillicola_presence(1=present,0=absent)')
WHERE mty_name ='anguillicola_proportion (visual)';

UPDATE "ref".tr_metrictype_mty SET (mty_name,mty_method, mty_individual_name) = 
('method_anguillicola_(1=stereomicroscope,0=visual_obs)
' , NULL,'method_anguillicola_(1=stereomicroscope,0=visual_obs)')
WHERE mty_name ='anguillicola_proportion (microscope)';
*/


INSERT INTO "ref".tr_metrictype_mty 
(mty_name
,mty_individual_name
,mty_description
,mty_type
,mty_method
,mty_uni_code
,mty_group
,mty_min
,mty_max) 
SELECT
'method_anguillicola_(1=stereomicroscope,0=visual_obs)' AS mty_name
,'method_anguillicola_(1=stereomicroscope,0=visual_obs)' AS mty_individual_name
,mty.mty_description
,mty.mty_type
,NULL AS mty_method
,mty.mty_uni_code
,mty.mty_group
,mty.mty_min
,mty.mty_max
FROM "ref".tr_metrictype_mty mty WHERE 
mty_name = 'anguillicola_proportion (visual)';
