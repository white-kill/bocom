<template>
  <div class="container">
    <nav-bar :title="title" :service-icon="serviceIcon"></nav-bar>
    <div class="main-container">
      <img class="image" :src="imageUrl" alt="">
    </div>
  </div>
</template>
<script>
export default {
  name: "publicPage",
  data() {
    return {
      title: this.$route.query.title || '',
      serviceIcon: this.$route.query.serviceIcon === "true",
      imageUrl: this.$route.query.imageUrl || '',
    }
  },
  mounted() {

  },
  methods: {},

}
</script>
<style scoped lang="scss">
.main-container {
  width: 100%;
  position: relative;

  .image {
    width: 100%;
    height: auto;
    display: block;
  }
}
</style>
