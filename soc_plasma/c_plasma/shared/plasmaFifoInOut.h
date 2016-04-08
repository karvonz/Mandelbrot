
void LoadImage(unsigned int *col_nb, unsigned int *row_nb, unsigned int *pixel_nb, unsigned char* data){
	 int i;
	 
	 	 // on recupere le nombre de colonnes dans l'image
	 *col_nb = i_read();
	 my_printf("nbre de colonnes dans l'image: ", *col_nb);

	 // on recupere le nombre de lignes dans l'image
	 *row_nb = i_read();
	 my_printf("nbre de lignes dans l'image: ", *row_nb);

	 *pixel_nb=(*col_nb)*(*row_nb);
	 my_printf("nbre de pixel dans l'image: ", *pixel_nb);

	 if( *pixel_nb > 32768 )
	 {
		puts("WARNING :image trop volumineuse, taille max = 32768 octets");
	 }

	 i=0;
	 while( i_empty() == 0 )//tant que la FIFO d'entree n'est pas vide
	 {
		data[i] = i_read();
		i++;
	 }
	 puts("Lecture de la FIFO d'entree terminee\n");
}

void StoreImage(unsigned int col_nb, unsigned int row_nb, unsigned char* data){
	 int pixel_nb, j;
	 o_write( col_nb);
	 o_write( row_nb);
	 o_write( 255 );
	 pixel_nb = (row_nb)*(col_nb);
	 puts("Ecriture des resultats dans la FIFO de sortie\n");
	 for( j = 0; j < pixel_nb; j++)
	 {
		  o_write( data[j] ); // j'ecrie la valeur dans la FIFO de sortie
	 }
}