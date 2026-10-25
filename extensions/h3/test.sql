CREATE EXTENSION h3;
CREATE EXTENSION h3_postgis CASCADE;

SELECT assert_true(h3_get_resolution(h3_lat_lng_to_cell(point(2.3522, 48.8566), 7)) = 7, 'h3: cell resolution');
SELECT assert_true(h3_lat_lng_to_cell(ST_Point(2.3522, 48.8566), 7) = h3_lat_lng_to_cell(point(2.3522, 48.8566), 7), 'h3_postgis: same cell from a geometry');
